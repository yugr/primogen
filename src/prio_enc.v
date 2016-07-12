module prio_enc #(
  parameter WIDTH_LOG = 4
) (
  input [(1 << WIDTH_LOG) - 1:0] x,
  output [7:0] msb
);

localparam WIDTH = 1 << WIDTH_LOG;

/* Concise but not supported by Icarus BLIF backend.

function [7:0] get_msb;
  input [HI:0] x;
  reg [7:0] bit;
  integer i;
  begin
    bit = 0;
    // TODO: this could be done by splitting in halves on each iteration
    for (i = HI; i >= 0; i = i - 1)
      if (!bit && x[i])
        bit = i;
    get_msb = bit;
  end
endfunction

always @*
  msb = get_msb(a);
*/

/* Fast but not synthesizable by Icarus BLIF backend

integer start, width;
reg [7:0] msb;

always @* begin
  start = 0;
  width = WIDTH;
  while (width > 1) begin
    width = width >> 1;
    start = (|(x >> width)) ? (start + width) : start;
  end
  msb = start;
end
*/

// Slow but Icarus fails at anything more complicated

integer i;
reg [7:0] msb;

always @* begin
  msb = 0;
  for (i = WIDTH - 1; i >= 0; i = i - 1)
    if (!msb && x[i])
      msb = i;
end

endmodule
