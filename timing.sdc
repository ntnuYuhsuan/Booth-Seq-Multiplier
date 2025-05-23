create_clock -period 20.000 -name my_main_clk [get_ports clk]
set_input_delay -max 3.000 -clock my_main_clk [get_ports {M[*] Q[*] load reset}]
set_input_delay -min 1.000 -clock my_main_clk [get_ports {M[*] Q[*] load reset}]
set_output_delay -max 4.000 -clock my_main_clk [get_ports P[*]]
set_output_delay -min 2.000 -clock my_main_clk [get_ports P[*]]