module primegen_tb;

reg clk = 0;
always #5 clk = !clk;

reg go = 0;
reg rst = 0;
reg [15:0] a = 0;
reg [15:0] b = 0;

wire gen_ready;
wire gen_error;
wire [15:0] gen_res;

primegen gen(
  .clk(clk),
  .go(go),
  .rst(rst),
  .ready(gen_ready),
  .error(gen_error),
  .res(gen_res));

`define CHECK(v) if (gen_res != v) $display("error: expected gen_res == %h (got %h)", v, gen_res);

reg [15:0] primes [31:0];
integer i;

initial begin
  // Need to test many cause of optimizations for first N primes
  primes[0] = 1;
  primes[1] = 2;
  primes[2] = 3;
  primes[3] = 5;
  primes[4] = 7;
  primes[5] = 11;
  primes[6] = 13;
  primes[7] = 17;
  primes[8] = 19;
  primes[9] = 23;
  primes[10] = 29;
  primes[11] = 31;

  @(negedge clk);
  rst = 1;
  @(posedge clk);
  @(negedge clk) rst = 0;
  #1000;

  for (i = 0; i <= 11; ++i) begin
    if (!gen_ready) begin
      $display("FAILED -- I=%d, READY=0", i);
      $finish;
    end else if (gen_res != primes[i]) begin
      $display("FAILED -- I=%d, PRIME=%d (should be %d)", i, gen_res, primes[i]);
      $finish;
    end

    // Ask for next prime
    @(negedge clk);
    go = 1;
    @(posedge clk);
    @(negedge clk) go = 0;
    #1000;
  end

  $finish;
end

//  initial
//    $monitor("%t: go = %b, ready = %b, error = %b, res = %h", $time, go, gen_ready, gen_error, gen_res);

endmodule

