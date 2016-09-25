`include "defines.vh"

module prio_enc #(
  parameter WIDTH_LOG = 4
) (x, msb);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

input [HI:0] x;

`define FAST_1
//`define FAST_2
//`define SLOW

`ifdef FAST_1

// This seems to compile to most cost-efficient
// implementation across all toolchains.

output reg [WIDTH_LOG - 1:0] msb;

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

`ifdef FAST_2

// The most low-level implementation. Surprinsingly it's not always
// the fastest...

output [WIDTH_LOG - 1:0] msb;

wire [WIDTH_LOG*WIDTH - 1:0] ors;
assign ors[WIDTH_LOG*WIDTH - 1:(WIDTH_LOG - 1)*WIDTH] = x;

genvar w, i;
integer j;

generate
  for (w = WIDTH_LOG - 1; w >= 0; w = w - 1) begin
    assign msb[w] = |ors[w*WIDTH + 2*(1 << w) - 1:w*WIDTH + (1 << w)];
    if (w > 0) begin
      assign ors[(w - 1)*WIDTH + (1 << w) - 1:(w - 1)*WIDTH] = msb[w] ? ors[w*WIDTH + 2*(1 << w) - 1:w*WIDTH + (1 << w)] : ors[w*WIDTH + (1 << w) - 1:w*WIDTH];
    end
  end
endgenerate

`endif

`ifdef SLOW

// Slow but simple. Some synthesizers are able
// to generate good RTL from this but not all.

output reg [WIDTH_LOG - 1:0] msb;

integer i;

always @* begin
  msb = 0;
  for (i = HI; i >= 0; i = i - 1)
    if (!msb && x[i])
      msb = i;
end

`endif

`ifdef SIM
//  initial
//    $monitor("%t: x=%b, msb=%b, ors=%b", $time, x, msb, ors);
`endif

endmodule
