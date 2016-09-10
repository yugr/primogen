// This is a benchmark for computing primes.
// It toggles central LED on completion.
// Surrounding LEDs are used to mark progress.

module bench (
  input clk,
  output LED[4:0]);

  // Not sure it's universally synthesizable
  // but ok for FPGA.
  reg rst = 1;
  reg [3:0] rst_count = 4'd15;

  // WLOG=5 (i.e. 32-bit primes) takes a LOT more time to build...
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  localparam MAX = {W{1'd1}};

  localparam LED_STEP_1 = MAX / 5'd16;
  localparam LED_STEP = LED_STEP_1 + (LED_STEP_1 * 5'd16 < MAX ? 1'd1 : 1'd0);
  reg [HI:0] leds_num;

  reg go;
  wire rdy, err;
  wire [HI:0] res;
  reg [HI:0] prime;

  primogen #(.WIDTH_LOG(WLOG)) pg(
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
        prime <= res;
      end
    end
  end

  // TODO: this does not seem to work...
  always @(posedge clk) begin
    if (rst_count == 4'd15)
      rst <= 0;
    else begin
      rst_count = rst_count + 1'd1;
    end
  end

  // This will be lit on overflow
  assign LED5 = err;

  // Show progress

  always @(posedge clk) begin
    if (rst) begin
      LED[3:0] <= 3'b0;
      leds_num <= 0;
    end else begin
      if (prime > leds_num) begin
        LED[3:0] <= LED[3:0] + 1'd1;
        leds_num <= leds_num + LED_STEP;
      end
    end
  end

endmodule
