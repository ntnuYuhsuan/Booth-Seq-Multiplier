module Booth_Seq_Multiplier(
    // Control signals
    input clk,       // Clock signal
    input load,      // Load input values
    input reset,     // Reset signal

    // Input operands
    input [3:0] M,   // Multiplicand (4-bit)
    input [3:0] Q,   // Multiplier (4-bit)
    
    // Output product
    output reg [7:0] P  // Product (8-bit)
);
    // Internal registers
    reg [3:0] A = 4'b0;           // Accumulator for partial products
    reg Q_m1 = 0;          // Previous bit of Q (Q[-1])
    reg [3:0] Q_temp = 4'b0;      // Working copy of multiplier
    reg [3:0] M_temp = 4'b0;      // Working copy of multiplicand
    reg [2:0] Count = 3'd4;       // Iteration counter
    
    // Main operation - Booth algorithm
    always @ (posedge clk) begin
        // Reset operation
        if (reset == 1) begin
            A = 4'b0;             // Clear accumulator
            Q_m1 = 0;      // Clear Q[-1]
            P = 8'b0;             // Clear product
            Q_temp = 4'b0;        // Clear temp multiplier
            M_temp = 4'b0;        // Clear temp multiplicand
            Count = 3'd4;         // Reset counter to 4 iterations
        end
        // Load operation
        else if (load == 1) begin
            Q_temp = Q;           // Load multiplier
            M_temp = M;           // Load multiplicand
        end
        // Booth algorithm operations - based on Q0 and Q-1
        else if ((Q_temp[0] == Q_m1) && (Count > 3'd0)) begin
            // Case 00 or 11: Only shift (no add/sub)
            Q_m1 = Q_temp[0];
            Q_temp = {A[0], Q_temp[3:1]};  // Right shift Q
            A = {A[3], A[3:1]};           // Arithmetic right shift A
            Count = Count - 1'b1;
        end
        else if ((Q_temp[0] == 0 && Q_m1 == 1) && (Count > 3'd0)) begin
            // Case 01: Add then shift
            A = A + M_temp;
            Q_m1 = Q_temp[0];
            Q_temp = {A[0], Q_temp[3:1]};  // Right shift Q
            A = {A[3], A[3:1]};           // Arithmetic right shift A
            Count = Count - 1'b1;
        end
        else if ((Q_temp[0] == 1 && Q_m1 == 0) && (Count > 3'd0)) begin
            // Case 10: Subtract then shift
            A = A - M_temp;
            Q_m1 = Q_temp[0];
            Q_temp = {A[0], Q_temp[3:1]};  // Right shift Q
            A = {A[3], A[3:1]};           // Arithmetic right shift A
            Count = Count - 1'b1;
        end
        else begin
            // Algorithm completed or invalid state
            Count = 3'b0;
        end
        
        // Assign final product
        P = {A, Q_temp};
    end
endmodule