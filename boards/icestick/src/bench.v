// This is a benchmark for computing primes.
// It toggles central LED on completion.
// Surrounding LEDs are used to mark progress.

module bench (
  input clk,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5);

  // Not sure it's universally synthesizable
  // but ok for FPGA.
  reg rst = 1;
  reg [3:0] rst_count = 4'd15;

  localparam W = 16;
  localparam HI = W - 1;

  reg go;
  wire rdy, err;
  wire [HI:0] res;

  primogen pg(
    .clk(clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));

  always @(posedge clk) begin
    if (rst) begin
      go <= 0;
    end else begin
      go <= 0;
      // !go - give primogen 1 clock to register inputs
      if (rdy && !err && !go) begin
        go <= 1;
      end
    end
  end

  always @(posedge clk) begin
    if (rst_count == 4'd15)
      rst <= 0;
    else begin
      rst_count = rst_count + 1'd1;
    end
  end

  localparam CHUNK = 16'd1 << (W - 2);

  // Show progress
  assign LED1 = res > 0;
  assign LED2 = res >= 2'd1 * CHUNK;
  assign LED3 = res >= 2'd2 * CHUNK;
  assign LED4 = res >= 2'd3 * CHUNK;

  // This will be lit on overflow
  assign LED5 = err;

endmodule
