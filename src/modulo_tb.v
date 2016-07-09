module modulo_tb;

reg clk = 0;
always #5 clk = !clk;

reg go = 0;
reg rst = 0;
reg [15:0] a = 0;
reg [15:0] b = 0;

wire m1_ready;
wire m1_error;
wire [15:0] m1_res;

modulo m1(
  .clk(clk),
  .go(go),
  .rst(rst),
  .a(a),
  .b(b),
  .ready(m1_ready),
  .error(m1_error),
  .res(m1_res));

`define CHECK(v) if (m1_res != v) $display("error: expected m1_res == %h (got %h)", v, m1_res);

reg [15:0] mod;

initial begin
  for (a = 0; a < 20; a = a + 1)
  for (b = 0; b < 20; b = b + 1) begin
    @(negedge clk);
    go = 1;
    @(posedge clk);
    @(negedge clk) go = 0;
    #100;
    mod = a % b;
    if (!m1_ready) begin
      $display("FAILED -- A=%d, B=%d, READY=0", a, b);
      $finish;
    end else if (mod != m1_res) begin
      $display("FAILED -- A=%d, B=%d, MOD=%d (should be %d)", a, b, m1_res, mod);
      $finish;
    end
  end
  $finish;
end

//  initial
//    $monitor("%t: go = %b, ready = %b, error = %b, res = %h", $time, go, m1_ready, m1_error, m1_res);

endmodule
