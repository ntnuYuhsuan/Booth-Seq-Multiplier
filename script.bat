iverilog -o booth_sim Booth_Seq_Multiplier.v Booth_Seq_Multiplier_tb.v
vvp booth_sim 
gtkwave booth_multiplier.vcd