module primogen_bench;

reg clk = 0;
reg go = 0;
wire rst;
reg [31:0] clk_count = 0;
reg [31:0] res_count = 0;
reg overflow = 0;

wire gen_ready;
wire gen_error;

por pos_inst(
  .clk(clk),
  .rst(rst));

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
  wait(!rst);

  while (clk_count < 20000) begin
    // Ask for next prime
    @(negedge clk) go = 1;
    @(posedge clk) @(negedge clk) go = 0;

    // Wait until prime is computed
    @(posedge gen_ready);
    if (gen_error)
      overflow = 1;

    if (!overflow)
      res_count = res_count + 1;
  end

  $display("primogen_bench SUCCEEDED: Computed %0d primes (in %0d cycles), %soverflow", res_count, clk_count, overflow ? "" : "no ");
  $finish;
end

//  initial
//    $monitor("%t: go = %b, ready = %b, error = %b, res = %h", $time, go, gen_ready, gen_error, gen_res);

endmodule


