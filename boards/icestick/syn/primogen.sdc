create_clock -name clk_12MHz -period 1000 -waveform {0.0 500.0} [get_ports clk_12MHz]
create_clock -name clk -period 1000 -waveform {0.0 500.0} [get_ports clk]
