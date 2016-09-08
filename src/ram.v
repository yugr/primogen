module ram #(
  parameter WIDTH = 16
) (
  input [WIDTH - 1:0] din,
  input wire [7:0] addr,  // TODO: support deeper RAMs
  input wire write_en,
  input clk,
  output wire [WIDTH - 1:0] dout);

`ifdef synthesis
This module is only meant for simulation
`endif

localparam HI = WIDTH - 1;

reg [HI:0] mem[7:0];

always @(posedge clk) begin
  if (write_en)
    mem[addr] <= din;
end

assign dout = mem[addr];

endmodule

