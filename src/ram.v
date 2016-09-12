module ram #(
  parameter WIDTH = 16,
  parameter ADDR_WIDTH = 8
) (
  input [WIDTH - 1:0] din,
  input wire [ADDR_WIDTH - 1:0] addr,
  input wire write_en,
  input clk,
  output reg [WIDTH - 1:0] dout);

`ifndef SIM
This module is only meant for simulation
`endif

localparam HI = WIDTH - 1;
localparam ADDR_HI = ADDR_WIDTH - 1;

reg [HI:0] mem[(1 << ADDR_WIDTH) - 1:0];

always @(posedge clk) begin
  if (write_en)
    mem[addr] <= din;
  dout <= mem[addr];
end

endmodule

