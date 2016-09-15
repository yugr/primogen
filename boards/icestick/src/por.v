module por(
  input clk,
  output rst);

  // Not sure it's universally synthesizable
  // but ok for iCEstick.

  // Assuming regs below are initialized to 0
  // (explicit init will trigger warnigns on some toolchains)
  reg por_done; /* synthesis syn_preserve = 1 */
  reg [3:0] count; /* synthesis syn_preserve = 1 */

  always @(posedge clk) begin
    if (!por_done)
      if (count == 4'd15) begin
        por_done <= 1;
      end else begin
        count <= count + 1'd1;
      end
  end

  assign rst = !por_done;

endmodule
