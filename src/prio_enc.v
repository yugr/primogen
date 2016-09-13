`include "defines.vh"

module prio_enc #(
  parameter WIDTH_LOG = 4
) (
  input [(1 << WIDTH_LOG) - 1:0] x,
  output reg [7:0] msb
);

localparam WIDTH = 1 << WIDTH_LOG;

`define FAST

`ifndef FAST
// Slow but simple

integer i;

always @* begin
  msb = 0;
  for (i = WIDTH - 1; i >= 0; i = i - 1)
    if (!msb && x[i])
      msb = i;
end
`else
// Faster but not sure that synthesizers will understand that interm. results
// is decreasing in size...

integer i, start, width;
reg [WIDTH - 1:0] part;

always @* begin
  start = 0;
  width = WIDTH;
  part = x;
  for (i = 0; i < WIDTH_LOG; i = i + 1) begin
    width = width >> 1;
    // Will synthesizer understand that part is two times smaller?!
    if (|(part >> width)) begin
      start = start + width;
      part = part >> width;
    end
    part = part & ((1'd1 << width) - 1'd1);
  end
  `assert_eq(width, 1)
  msb = start;
end
`endif

endmodule
