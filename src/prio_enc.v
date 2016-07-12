module prio_enc #(
  parameter WIDTH_LOG = 4
) (
  input [(1 << WIDTH_LOG) - 1:0] x,
  output [7:0] msb
);

localparam WIDTH = 1 << WIDTH_LOG;

`ifndef FAST_ENCODER
// Slow but simple

integer i;
reg [7:0] msb;

always @* begin
  msb = 0;
  for (i = WIDTH - 1; i >= 0; i = i - 1)
    if (!msb && x[i])
      msb = i;
end
`else
// Faster

integer i, start, width;
reg [7:0] msb;

always @* begin
  start = 0;
  width = WIDTH;
  for (i = 0; i < WIDTH_LOG - 1; i = i + 1) begin
    width = width >> 1;
    start = (|(x >> width)) ? (start + width) : start;
  end
  msb = start;
end
`endif

endmodule
