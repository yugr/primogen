module top (
  input clk,
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5);

  reg [23:0] clk_count;
  reg clk_sec;

  // TODO: not sure it's universally synthesizable...
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
  localparam DIV = 24'd12000000 / 2;

  always @(posedge clk) begin
    if (rst) begin
      clk_sec <= 1;
      clk_count <= 0;
    end else begin
      if (clk_count == DIV) begin
        clk_sec <= ~clk_sec;
        clk_count <= 24'd0;
      end else begin
        clk_count <= clk_count + 24'd1;
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
      if (rdy && !go) begin
        go <= 1;
        prime <= res;
      end
    end
  end

  always @(posedge clk) begin
    if (rst_count == 4'd15)
      rst <= 0;
    else begin
      rst_count = rst_count + 1;
    end
  end

  // Dummy

  reg [4:0] count;

  always @(posedge clk_sec) begin
    count <= count + 5'b1;
  end

  assign LED1 = count[0];
  assign LED2 = count[1];
  assign LED3 = count[2];
  assign LED4 = count[3];
  assign LED5 = count[4];

endmodule
