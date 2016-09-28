module primogen_tb;

reg clk = 0;

reg go = 0;
wire rst;
reg [15:0] a = 0;
reg [15:0] b = 0;

wire gen_ready;
wire gen_error;
wire [15:0] gen_res;

parameter N = 13;
reg [99:0] primes [31:0];
integer i;

por pos_inst(
  .clk(clk),
  .rst(rst));

primogen gen(
  .clk(clk),
  .go(go),
  .rst(rst),
  .ready(gen_ready),
  .error(gen_error),
  .res(gen_res));

always #5 clk = !clk;

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
  primes[12] = 37;

  for (i = N; i < 100; i = i + 1)
    primes[i] = 0;

  wait (!rst);

  for (i = 0; i < N; ++i) begin
    if (!gen_ready) begin
      $error("FAILED -- I=%d, READY=0", i);
    end else if (gen_error) begin
      $error("FAILED -- I=%d, ERROR=1", i);
    end else if (^gen_res === 1'bx) begin
      $error("FAILED -- I=%d, UNDEF (%d)", i, gen_res);
    end else if (gen_res != primes[i]) begin
      $error("FAILED -- I=%d, PRIME=%d (should be %d)", i, gen_res, primes[i]);
    end

    // Ask for next prime
    @(negedge clk);
    go = 1;
    @(posedge clk);
    @(negedge clk) go = 0;

    @(posedge gen_ready);
  end

  $display("primogen_tb ENDED");
  $finish;
end

//  initial
//    $monitor("%t: go = %b, ready = %b, error = %b, res = %h", $time, go, gen_ready, gen_error, gen_res);

endmodule

