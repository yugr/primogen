// Arbitrary-sized RAM.
//
// Both Lattice and Synopsis do not seem
// to be capable of infering cascaded BRAMs
// out-of-the-box, hence the mess below.

module ram #(
  parameter WIDTH = 16,
  parameter ADDR_WIDTH = 8
) (
  input [WIDTH - 1:0] din,
  input wire [ADDR_WIDTH - 1:0] addr,
  input wire write_en,
  input clk,
  output reg [WIDTH - 1:0] dout);

localparam HI = WIDTH - 1;

localparam NWORDS = (WIDTH + 15) / 16;
localparam WIDTH_PAD = NWORDS * 16 - WIDTH;
localparam WIDTH_ALIGN = NWORDS * 16;

// Address
//   addr[ADDR_WIDTH - 1:0]
// is split to 'offset' (in 16-bit words):
//   offset = addr[7:0]
// and 'selector':
//   sel = addr[ADDR_WIDTH - 1:8]
// The 8-bit 'offset' part can be mapped to block RAM
// and 'sel' is then implemented on top of it as mux.

localparam SEL_WIDTH = ADDR_WIDTH <= 8 ? 0 : ADDR_WIDTH - 8;
localparam NSEL = 1 << SEL_WIDTH;

wire [WIDTH_ALIGN - 1:0] din_pad;
wire [NSEL*WIDTH_ALIGN - 1:0] douts;

wire [7:0] offset;
wire [SEL_WIDTH - 1:0] sel;

assign din_pad = din;

assign offset = addr[7:0];
assign sel = NSEL == 1 ? 1'b0 : addr[ADDR_WIDTH - 1:8];

genvar i, j;
generate
  for(i = 0; i < NSEL; i = i + 1) begin
  for(j = 0; j < WIDTH_ALIGN; j = j + 16) begin
    ram256x16 bank (
      .din(din_pad[j + 15:j]),
      .addr(offset),
      .write_en(write_en & (sel == i)),  // TODO: use decoder?
      .clk(clk),
      .dout(douts[i*WIDTH_ALIGN + j + 15:i*WIDTH_ALIGN + j]));
  end
  end
endgenerate

integer k, l;

always @* begin
  dout = {WIDTH{1'bx}};
  for(k = 0; k < NSEL; k = k + 1) begin
    if (sel == k)  // TODO: use decoder?
      for (l = 0; l < WIDTH; l = l + 1)
        dout[l] = douts[k*WIDTH_ALIGN + l];
  end
end

endmodule

