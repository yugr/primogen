`ifdef SIM
This file shouldn't be used in simulation...
`endif

// Hopefully 256x16 is universally synthesizable
// across different HW/tools vendors (otherwise
// we can switch to 512x8).
//
// TODO: implement for Yosys as well
module ram256x16(
  input [15:0] din,
  input [7:0] addr,
  input write_en,
  input clk,
  output [15:0] dout);

//`define OLD 1

`ifdef OLD

// This does not seem to work...

reg [15:0] mem [7:0];  // 16 * 256 == 4K

always @(posedge clk) begin
  if (write_en)
    mem[addr] <= din;
end

assign dout = mem[addr];

`else

SB_RAM256x16 ram_inst (
  .RDATA(dout),
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

