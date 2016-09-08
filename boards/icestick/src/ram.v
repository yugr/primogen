// From iCEcube UG
module ram256x8(
  input [15:0] din,
  input [7:0] addr,
  input write_en,
  input clk,
  output [15:0] dout);

reg [15:0] mem [7:0];

always @(posedge clk) begin
  if (write_en)
    mem[addr] <= din;
end

assign dout = mem[addr];

endmodule

module ram #(
  parameter WIDTH = 16
) (
  input [WIDTH - 1:0] din,
  input wire [7:0] addr,  // TODO: support deeper RAMs
  input wire write_en,
  input clk,
  output wire [WIDTH - 1:0] dout);

localparam HI = WIDTH - 1;

localparam NWORDS = (WIDTH + 15) / 16;
localparam PAD = NWORDS * 16 - WIDTH;
localparam WIDTH_ALIGN = NWORDS * 16;
localparam HI_ALIGN = WIDTH_ALIGN - 1;

wire [HI_ALIGN:0] din_exp;
wire [HI_ALIGN:0] dout_exp;

assign din_exp = {{PAD{1'b0}}, din};
assign dout = dout_exp[HI:0];

// Lattice toolchains don't seem to support cascaded BRAMs
// out-of-the-box, hence the mess below.
//
// I could have merged banks to single BRAM block to save gates
// but I'm not sure if that's universally synthesizable.

genvar i;
generate
  for(i = 0; i < WIDTH_ALIGN; i = i + 16) begin
    ram256x8 bank (
      .din(din_exp[i + 15:i]),
      .addr(addr[7:0]),
      .write_en(write_en),
      .clk(clk),
      .dout(dout_exp[i + 15:i]));
  end
endgenerate

endmodule

