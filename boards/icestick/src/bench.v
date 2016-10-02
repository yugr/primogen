// This is a benchmark for computing primes.
// It toggles central LED on completion.
// Surrounding LEDs are used to mark progress.

module bench (
  input clk_12MHz,
  output reg [4:0] LED);

  // WLOG=5 (i.e. 32-bit primes) takes a LOT more time to build...
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  localparam MAX = {W{1'd1}};

  localparam COUNT_PER_LED_TICK = MAX / 5'd16 + 1'd1;
  reg [HI:0] bound;

  reg go;
  wire rdy, err;
  wire [HI:0] res;
  reg [HI:0] prime;

  wire rst;
  wire clk;

  // TODO: pass from outside and verify?
  localparam F = 16;

  clk_gen #(.F(F)) clk_gen_inst (.clk_12MHz(clk_12MHz), .clk(clk));
  por por_inst(.clk(clk), .rst(rst));

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

  // Show progress

  always @(posedge clk) begin
    if (rst) begin
      bound <= COUNT_PER_LED_TICK;
    end else begin
      LED[4] <= err;
      if (prime > bound) begin
        bound <= bound + COUNT_PER_LED_TICK;
        LED[3:0] <= LED[3:0] + 1'd1;
      end
    end
  end

endmodule
