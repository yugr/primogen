module por(
  input clk,
  output rst);

  reg [3:0] count = 4'd15;

  always @(posedge clk)
    if (count)
      count <= count - 1'd1;

  assign rst = |count;

endmodule
