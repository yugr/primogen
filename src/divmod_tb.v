module divmod_tb;

reg clk = 0;

reg go = 0;
reg rst = 0;
reg [15:0] num = 0;
reg [15:0] den = 0;

wire m1_ready;
wire m1_error;
wire [15:0] m1_div;
wire [15:0] m1_mod;

reg [15:0] quot;
reg [15:0] rem;

divmod dm1(
  .clk(clk),
  .go(go),
  .rst(rst),
  .num(num),
  .den(den),
  .ready(m1_ready),
  .error(m1_error),
  .quot(m1_div),
  .rem(m1_mod));

always #5 clk = !clk;

initial begin

  @(negedge clk);
  rst = 1;
  @(posedge clk);
  @(negedge clk) rst = 0;
  #10;

  for (num = 0; num < 20; num = num + 1)
  for (den = 0; den < 20; den = den + 1) begin
    @(negedge clk);
    go = 1;
    @(posedge clk);
    @(negedge clk) go = 0;
    #100;
    rem = num / den;
    quot = num % den;
    if (!m1_ready) begin
      $display("FAILED -- A=%d, B=%d, READY=0", num, den);
      $finish(1);
    end else if (den != 0 && (^m1_div === 1'bx || ^m1_mod === 1'bx)) begin
      $display("FAILED -- A=%d, B=%d, UNDEF (%d %d)", num, den, m1_div, m1_mod);
      $finish(1);
    end else if (rem != m1_div) begin
      $display("FAILED -- A=%d, B=%d, DIV=%d (should be %d)", num, den, m1_div, rem);
      $finish(1);
    end else if (quot != m1_mod) begin
      $display("FAILED -- A=%d, B=%d, MOD=%d (should be %d)", num, den, m1_mod, quot);
      $finish(1);
    end
  end
  $display("divmod_tb SUCCEEDED");
  $finish;
end

//  initial
//    $monitor("%t: go=%den, ready=%den, error=%den, rem=%h, quot=%h", $time, go, m1_ready, m1_error, m1_div, m1_mod);

endmodule
