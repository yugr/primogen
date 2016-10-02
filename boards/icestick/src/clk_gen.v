// Based on https://github.com/SubProto/icestick-vga-test

module clk_gen #(
  parameter F = 16
) (
  input clk_12MHz,
  output clk);

// Divider coefficients obtained with icepll.exe

localparam DIVR =
  F == 16 ? 0 :
  F == 36 ? 0 :
  -1;

localparam DIVF =
  F == 16 ? 84 :
  F == 36 ? 47 :
  -1;

localparam DIVQ =
  F == 16 ? 6 :
  F == 36 ? 4 :
  -1;

localparam FR =
  F == 16 ? 1 :
  F == 36 ? 1 :
  -1;

generate
  if (DIVF < 0)
    unsupported_clock_frequency m();
endgenerate

SB_PLL40_CORE #(
  .FEEDBACK_PATH("SIMPLE"),
  .PLLOUT_SELECT("GENCLK"),
  .DIVR(DIVR),
  .DIVF(DIVF),
  .DIVQ(DIVQ),
  .FILTER_RANGE(FR)) pll (
  .REFERENCECLK(clk_12MHz),
  .PLLOUTCORE(clk),
  .RESETB(1'b1),
  .BYPASS(1'b0));

endmodule

