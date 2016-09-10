// A dummy module for experiments with BRAM.

module ram #(
  parameter WIDTH = 16,
  parameter ADDR_WIDTH = 8
) (
  input [WIDTH - 1:0] din,
  input [ADDR_WIDTH - 1:0] addr,
  input write_en,
  input clk,
  output [WIDTH - 1:0] dout);

  reg [WIDTH - 1:0] mem [ADDR_WIDTH - 1:0];  // 16 * 256 == 4K

  always @(posedge clk) begin
    if (write_en)
      mem[addr] <= din;
  end

  assign dout = mem[addr];
endmodule

module ram_test (
  input clk,
  output LED1);

  localparam WIDTH = 16;
  localparam ADDR_WIDTH = 8;

  reg [ADDR_WIDTH - 1:0] addr;
  reg [WIDTH - 1:0] din;
  wire [WIDTH - 1:0] dout;
  reg write_en;

  // Triggers "Input port bits 7 to 3 of addr[7:0] are unused."
  ram ram_inst(
    .din(din),
    .dout(dout),
    .write_en(write_en),
    .addr(addr),
    .clk(clk)
  );

  always @(posedge clk) begin
    addr <= addr + 2'd3;
    write_en <= ~write_en;
    din <= dout + 1'd1;
  end

  assign LED1 = ^dout[0];
endmodule
