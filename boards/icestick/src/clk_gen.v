// Based on https://github.com/SubProto/icestick-vga-test

module clk_gen #(
  parameter F = 16
) (
  input clk_12MHz,
  output clk,
  output ready);

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

localparam nbufs = 4;

wire lock;
reg [nbufs - 1:0] lock_buf;

SB_PLL40_CORE #(
  .FEEDBACK_PATH("SIMPLE"),
  .PLLOUT_SELECT("GENCLK"),
  .DIVR(DIVR),
  .DIVF(DIVF),
  .DIVQ(DIVQ),
  .FILTER_RANGE(FR)) pll (
  .REFERENCECLK(clk_12MHz),
  .PLLOUTCORE(clk),
  .LOCK(lock),
  .RESETB(1'b1),
  .BYPASS(1'b0));

// Lock may not be synched with clk...
// http://stackoverflow.com/questions/38030768/icestick-yosys-using-the-global-set-reset-gsr
always @(posedge clk)
  lock_buf <= {lock_buf[nbufs - 2:0], lock};

assign ready = lock_buf[nbufs - 1];

endmodule

