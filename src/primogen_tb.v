`include "defines.vh"

module primogen_tb;

reg clk = 0;
wire rst;

reg go = 0;

wire gen_ready;
wire gen_error;
wire [15:0] gen_res;

localparam N = 50;
reg [15:0] primes [N - 1:0];
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
  primes[13] = 41;
  primes[14] = 43;
  primes[15] = 47;
  primes[16] = 53;
  primes[17] = 59;
  primes[18] = 61;
  primes[19] = 67;
  primes[20] = 71;
  primes[21] = 73;
  primes[22] = 79;
  primes[23] = 83;
  primes[24] = 89;
  primes[25] = 97;
  primes[26] = 101;
  primes[27] = 103;
  primes[28] = 107;
  primes[29] = 109;
  primes[30] = 113;
  primes[31] = 127;
  primes[32] = 131;
  primes[33] = 137;
  primes[34] = 139;
  primes[35] = 149;
  primes[36] = 151;
  primes[37] = 157;
  primes[38] = 163;
  primes[39] = 167;
  primes[40] = 173;
  primes[41] = 179;
  primes[42] = 181;
  primes[43] = 191;
  primes[44] = 193;
  primes[45] = 197;
  primes[46] = 199;
  primes[47] = 211;
  primes[48] = 223;
  primes[49] = 227;

  wait (!rst);

  for (i = 0; i < N; ++i) begin
    if (!gen_ready) begin
      $fatal(1, "FAILED -- I=%d, READY=0", i);
    end else if (gen_error) begin
      $fatal(1, "FAILED -- I=%d, ERROR=1", i);
    end else if (`isunknown(gen_res)) begin
      $fatal(1, "FAILED -- I=%d, UNDEF (%d)", i, gen_res);
    end else if (gen_res != primes[i]) begin
      $fatal(1, "FAILED -- I=%d, PRIME=%d (should be %d)", i, gen_res, primes[i]);
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

