`timescale 1ns/ 1ps

module Booth_Seq_Multiplier_tb;

    // Inputs
    reg clk;
    reg load;
    reg reset;
    reg [3:0] M;
    reg [3:0] Q;

    // Outputs
    wire [7:0] P;
    
    // Internal signals for monitoring
    wire [3:0] A_monitor;
    wire Q_minus_one_monitor;
    wire [3:0] Q_temp_monitor;
    wire [2:0] Count_monitor;
    
    // Iteration counter for display
    integer iter_count = 0;
    reg [2:0] prev_count = 0;  // 添加這行來定義先前的計數值

    // Clock period definition
    parameter CLOCK_PERIOD = 20;

    // Instantiate the Unit Under Test (UUT)
    Booth_Seq_Multiplier dut (
        .clk(clk), 
        .load(load), 
        .reset(reset), 
        .M(M), 
        .Q(Q), 
        .P(P)
    );
    
    // For debug monitoring
    assign A_monitor = dut.A;
    assign Q_minus_one_monitor = dut.Q_minus_one;
    assign Q_temp_monitor = dut.Q_temp;
    assign Count_monitor = dut.Count;
    
    // Clock generation
    always #(CLOCK_PERIOD/2) clk = ~clk;
    
    // Time tracking
    time start_time, end_time;
    reg done_flag = 0;
    
    // Monitor multiplication progress
    always @(posedge clk) begin

        if (reset) begin
            done_flag = 0;
            iter_count = 0;
            prev_count = 0;  // 在reset時重置prev_count
        end

        if (load && !done_flag) begin
            start_time = $time;
            iter_count = 0;
            prev_count = 4;  // 初始化為4，因為Count從4開始
            $display("Time: %0t ns - Starting multiplication: %0d x %0d", 
                     $time, $signed(M), $signed(Q));
        end
        
        if (!reset && !load && Count_monitor != 0 && Count_monitor != prev_count) begin
            iter_count = 4 - Count_monitor;
            $display("Time: %0t ns - Iteration %0d: A=%b, Q=%b, Q[-1]=%b", 
                    $time, iter_count, A_monitor, Q_temp_monitor, Q_minus_one_monitor);
            prev_count = Count_monitor;  // 更新prev_count
        end
        
        if (!reset && !load && Count_monitor == 0 && !done_flag) begin
            end_time = $time;
            done_flag = 1;
            $display("Time: %0t ns - Multiplication complete!", $time);
            $display("Time: %0t ns - Final result: %0d x %0d = %0d (binary: %b)", 
                    $time, $signed(M), $signed(Q), $signed(P), P);
            $display("Time: %0t ns - Computation took %0d clock cycles (%0d ns)", 
                    $time, (end_time-start_time)/CLOCK_PERIOD, (end_time-start_time));
        end
    end
  
    // Test case execution
    initial begin
        // Initialize waveform dumps
        $dumpfile("booth_multiplier.vcd");
        $dumpvars(0, Booth_Seq_Multiplier_tb);
        
        // Test case title
        $display("====== BOOTH SEQUENTIAL MULTIPLIER TESTBENCH ======");
        
        // Initialize Inputs
        clk = 0;
        load = 0;
        reset = 1;
        M = 0;
        Q = 0;
        done_flag = 0;
        prev_count = 0;  // 初始化prev_count
        
        // Wait for global reset
        #(CLOCK_PERIOD*2);
        
        // Test Case 1: Positive x Positive (5 x 3 = 15)
        reset = 1;
        #CLOCK_PERIOD;
        reset = 0;
        M = 4'b0101;  // 5 in decimal
        Q = 4'b0011;  // 3 in decimal
        load = 1;
        #CLOCK_PERIOD;
        load = 0;
        
        // Wait for multiplication to complete
        wait(Count_monitor == 0);
        #(CLOCK_PERIOD*2);
        
        // Test Case 2: Negative x Positive (-5 x 3 = -15)
        reset = 1;
        #CLOCK_PERIOD;
        reset = 0;
        M = 4'b1011;  // -5 in 2's complement
        Q = 4'b0011;  // 3 in decimal
        load = 1;
        #CLOCK_PERIOD;
        load = 0;
        
        // Wait for multiplication to complete
        wait(Count_monitor == 0);
        #(CLOCK_PERIOD*2);
        
        // Test Case 3: Negative x Negative (-6 x -5 = 30)
        reset = 1;
        #CLOCK_PERIOD;
        reset = 0;
        M = 4'b1010;  // -6 in 2's complement
        Q = 4'b1011;  // -5 in 2's complement
        load = 1;
        #CLOCK_PERIOD;
        load = 0;
        
        // Wait for multiplication to complete
        wait(Count_monitor == 0);
        #(CLOCK_PERIOD*2);
        
        // End simulation
        $display("====== SIMULATION COMPLETE ======");
        $finish;
    end
endmodule