// This computes new prime every 5 seconds
// and displays lower 5 bits via LEDs.

module blink (
  input clk,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5);

  reg [27:0] clk_count;
  reg pulse_5_sec;

  // Not sure it's universally synthesizable
  // but ok for FPGA.
  reg rst = 1;
  reg [3:0] rst_count = 4'd15;

  localparam HI = 15;

  reg go;
  wire rdy, err;
  wire [HI:0] res;
  reg [HI:0] prime;

  primogen pg(
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
      prime <= 0;
    end else begin
      go <= 0;
      // !go - give primogen 1 clock to register inputs
      if (rdy && !err && !go && pulse_5_sec) begin
        go <= 1;
        prime <= res;
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

  assign LED1 = prime[0];
  assign LED2 = prime[1];
  assign LED3 = prime[2];
  assign LED4 = prime[3];
  assign LED5 = prime[4];

endmodule
