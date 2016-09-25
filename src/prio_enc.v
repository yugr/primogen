`include "defines.vh"

module prio_enc #(
  parameter WIDTH_LOG = 4
) (x, msb);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

input [HI:0] x;
output reg [7:0] msb;

`define FAST

`ifndef FAST

// Slow but simple. Some synthesizers are able
// to generate good RTL from this but not all.

integer i;

always @* begin
  msb = 0;
  for (i = HI; i >= 0; i = i - 1)
    if (!msb && x[i])
      msb = i;
end

`else

integer i, width;
reg [HI:0] part;

always @* begin
  msb = 0;
  part = x;
  for (i = WIDTH_LOG - 1; i >= 0; i = i - 1) begin
    width = 1 << i;
    if (|(part >> width))
      msb[i] = 1;
    // Hopefully synthesizer understands that 'part' is shrinking...
    part = msb[i] ? part >> width : part & ((1'd1 << width) - 1'd1);
  end
end

`endif

endmodule
