module divmod_tb;

reg clk = 0;

reg go = 0;
reg rst = 0;
reg [15:0] a = 0;
reg [15:0] b = 0;

wire m1_ready;
wire m1_error;
wire [15:0] m1_div;
wire [15:0] m1_mod;

reg [15:0] rem;
reg [15:0] quot;

divmod dm1(
  .clk(clk),
  .go(go),
  .rst(rst),
  .a(a),
  .b(b),
  .ready(m1_ready),
  .error(m1_error),
  .rem(m1_div),
  .quot(m1_mod));

always #5 clk = !clk;

initial begin

  @(negedge clk);
  rst = 1;
  @(posedge clk);
  @(negedge clk) rst = 0;
  #10;

  for (a = 0; a < 20; a = a + 1)
  for (b = 0; b < 20; b = b + 1) begin
    @(negedge clk);
    go = 1;
    @(posedge clk);
    @(negedge clk) go = 0;
    #100;
    rem = a / b;
    quot = a % b;
    if (!m1_ready) begin
      $display("FAILED -- A=%d, B=%d, READY=0", a, b);
      $finish(1);
    end else if (b != 0 && (^m1_div === 1'bx || ^m1_mod === 1'bx)) begin
      $display("FAILED -- A=%d, B=%d, UNDEF (%d %d)", a, b, m1_div, m1_mod);
      $finish(1);
    end else if (rem != m1_div) begin
      $display("FAILED -- A=%d, B=%d, DIV=%d (should be %d)", a, b, m1_div, rem);
      $finish(1);
    end else if (quot != m1_mod) begin
      $display("FAILED -- A=%d, B=%d, MOD=%d (should be %d)", a, b, m1_mod, quot);
      $finish(1);
    end
  end
  $display("divmod_tb SUCCEEDED");
  $finish;
end

//  initial
//    $monitor("%t: go=%b, ready=%b, error=%b, rem=%h, quot=%h", $time, go, m1_ready, m1_error, m1_div, m1_mod);

endmodule
