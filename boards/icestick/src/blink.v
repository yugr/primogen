// This computes new prime every 5 seconds
// and displays lower 5 bits via LEDs.

module blink (
  input clk,
  output [4:0] LED);

  reg [27:0] clk_count;
  reg pulse_5_sec;

  // WLOG=5 (i.e. 32-bit primes) takes a LOT more time to build...
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;

  reg go;
  wire rdy, err;
  wire [HI:0] res;

  wire rst;

  por por_isnt(.clk(clk), .rst(rst));

  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));

  // clk is 12 MHz
  localparam DIV = 28'd12000000 * 28'd5;

  always @(posedge clk) begin
    if (rst) begin
      pulse_5_sec <= 0;
      clk_count <= 0;
    end else begin
      if (clk_count == DIV) begin
        pulse_5_sec <= 1;
        clk_count <= 1'd0;
      end else begin
        pulse_5_sec <= 0;
        clk_count <= clk_count + 1'd1;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      go <= 0;
    end else begin
      go <= 0;
      // !go - give primogen 1 clock to register inputs
      if (rdy && !err && !go && pulse_5_sec) begin
        go <= 1;
      end
    end
  end

  assign LED[3:0] = res[3:0];
  assign LED[4] = err;

endmodule
