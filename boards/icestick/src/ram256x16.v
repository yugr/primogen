`ifdef SIM
This file shouldn't be used in simulation...
`endif

// Disable to use BRAM primitives
`define INFER_BRAM 1

// Hopefully 256x16 is universally synthesizable
// across different HW/tools vendors (otherwise
// we can switch to 512x8).
module ram256x16(
  input [15:0] din,
  input [7:0] addr,
  input write_en,
  input clk,

`ifdef INFER_BRAM
  output reg [15:0] dout);

reg [15:0] mem [255:0];  // 16 * 256 == 4K

always @(posedge clk) begin
  if (write_en)
    mem[addr] <= din;
  dout <= mem[addr];
end

`else
  output [15:0] dout);

SB_RAM256x16 ram_inst (
  .RDATA(out),
  .RADDR(addr),
  .RCLK(clk),
  .RCLKE(1'b1),
  .RE(~write_en),
  .WADDR(addr),
  .WCLK(clk),
  .WCLKE(1'b1),
  .WDATA(din),
  .WE(write_en),
  .MASK(16'b0)  // Negative logic
);

`endif

endmodule

