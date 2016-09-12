module primogen_bench;

reg clk = 0;
reg go = 0;
reg rst = 0;
reg [31:0] clk_count = 0;
reg [31:0] res_count = 0;

wire gen_ready;
wire gen_error;

primogen gen(
  .clk(clk),
  .go(go),
  .rst(rst),
  .ready(gen_ready),
  .error(gen_error));

always #1 clk = !clk;

always @(posedge clk)
  clk_count = clk_count + 1;

initial begin
  @(negedge clk);
  rst = 1;
  @(posedge clk);
  @(negedge clk) rst = 0;
  #10;

  while (clk_count < 20000) begin
    // Ask for next prime
    @(negedge clk) go = 1;
    @(posedge clk) @(negedge clk) go = 0;

    // Wait until prime is computed
    @(posedge gen_ready) res_count = res_count + 1;
  end

  $display("primogen_bench SUCCEEDED: Computed %0d primes (in %0d cycles)", res_count, clk_count);
  $finish;
end

//  initial
//    $monitor("%t: go = %b, ready = %b, error = %b, res = %h", $time, go, gen_ready, gen_error, gen_res);

endmodule


