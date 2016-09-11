`include "defines.vh"

module primogen #(
  parameter WIDTH_LOG = 4
) (
  input clk,
  input go,
  input rst,
  output reg ready,
  output reg error,
  output reg [(1 << WIDTH_LOG) - 1:0] res
);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

// Note that incrementing width by 1 bit
// would double BRAM consumption
localparam ADDR_WIDTH = 8;
localparam ADDR_HI = ADDR_WIDTH - 1;
`ifdef SIM
// Use reduced RAM for tests
localparam ADDR_MAX = 3'd4;
`else
localparam ADDR_MAX = {ADDR_WIDTH{1'b1}};
`endif

localparam XW = {WIDTH{1'bx}};
localparam X7 = 7'bx;
localparam XA = {ADDR_WIDTH{1'bx}};

localparam READY = 4'd0;
localparam ERROR = 4'd1;
localparam NEXT_CANDIDATE = 4'd2;
localparam NEXT_PRIME_DIVISOR = 4'd3;
localparam PRIME_DIVIDE_DLY = 4'd4;  // TODO: can we get rid of this?
localparam PRIME_DIVIDE_WAIT = 4'd5;
localparam NEXT_DIVISOR = 4'd6;
localparam DIVIDE_DLY = 4'd7;  // TODO: can we get rid of this?
localparam DIVIDE_WAIT = 4'd8;

// Combinational logic for outputs
reg [HI:0] next_res;
wire next_ready;
wire next_error;

// State
reg [3:0] state;

// And it's combinational logic
reg [3:0] next_state;

// Submodule inputs
reg [HI:0] div;
reg [HI:0] div_squared;
reg div_go;
reg [ADDR_HI:0] addr;
reg [ADDR_HI:0] naddrs;
reg write_en;

// And their combinational logic
reg [HI:0] next_div;
reg [HI:0] next_div_squared;
reg next_div_go;
reg [ADDR_HI:0] next_addr;
reg [ADDR_HI:0] next_naddrs;
reg next_write_en;

// Submodule outputs
wire div_ready;
wire div_error;
wire [HI:0] rem;
wire [HI:0] dout;

ram #(.WIDTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) primes(
  .din(res),
  .addr(next_addr),  // Save one cycle by feeding combinational input
  .write_en(write_en),
  .clk(clk),
  .dout(dout)
);

divrem #(.WIDTH_LOG(WIDTH_LOG)) d_m(
  .clk(clk),
  .go(div_go),
  .rst(rst),
  .num(res),
  .den(div),
  .ready(div_ready),
  .error(div_error),
  .rem(rem));

assign next_ready = next_state == READY || next_state == ERROR;
assign next_error = next_state == ERROR;

always @* begin
  next_state = state;
  next_res = res;

  next_div = div;
  next_div_squared = div_squared;
  next_div_go = 0;
  next_addr = addr;
  next_naddrs = naddrs;
  next_write_en = 0;

  case (state)
    READY, ERROR:
      if (go)
        next_state = NEXT_CANDIDATE;

    NEXT_CANDIDATE:  // TODO: can probably be merged with NEXT_PRIME_DIVISOR
      begin
        // Search for next prime
        case (res)
          1: next_res = 8'd2;
          2: next_res = 8'd3;
          default: next_res = res + 8'd2;
        endcase

        if (next_res > res) begin
          next_state = NEXT_PRIME_DIVISOR;
          next_addr = 0;
        end else begin
          // Overflow
          next_state = ERROR;
        end
      end

    NEXT_PRIME_DIVISOR:
      if (addr < naddrs) begin
        next_state = PRIME_DIVIDE_DLY;
        next_div = dout;
        next_div_go = 1;
      end else if (naddrs == ADDR_MAX) begin
        // Prime table overflow => use slow check
        next_state = NEXT_DIVISOR;
        next_div = 8'd2;
        next_div_squared = 8'd4;
        // TODO: we could start immediately from last prime divisor
        // but we need to store prime squares as well.
      end else begin
        next_state = READY;
        // Store found prime
        if (res != 1'd1 && res != 2'd2) begin
          next_write_en = 1'd1;
          next_naddrs = naddrs + 1'd1;
        end
      end

    PRIME_DIVIDE_DLY:
      // Wait state to allow divrem to register inputs and update ready bit
      next_state = PRIME_DIVIDE_WAIT;

    PRIME_DIVIDE_WAIT:
      if (div_error) begin
        next_state = ERROR;
      end else if (!div_ready)
        ; // Keep waiting
      else if (rem == 0) begin
        // Divisable => abort and try next candidate
        next_state = NEXT_CANDIDATE;
      end else begin
        // Not divisable => try next divisor
        next_state = NEXT_PRIME_DIVISOR;
        next_addr = addr + 1'd1;
      end

    NEXT_DIVISOR:
      if (div_squared > res) begin
        // None of potential divisors matched => number is prime!
        next_state = READY;
      end else begin
        next_state = DIVIDE_DLY;
        next_div_go = 1;
      end

    DIVIDE_DLY:
      // Wait state to allow divrem to register inputs and update ready bit
      next_state = DIVIDE_WAIT;

    DIVIDE_WAIT:
      if (div_error) begin
        next_state = ERROR;
      end else if (!div_ready)
        ; // Keep waiting
      else if (rem == 0) begin
        // Divisable => abort and try next candidate
        next_state = NEXT_CANDIDATE;
      end else begin
        // Not divisable => try next divisor
        case (div)
          2:
            begin
              next_div = 8'd3;
              next_div_squared = 8'd9;
            end
          7:
            begin
              next_div = 8'd11;
              next_div_squared = 8'd121;
            end
          // 3, 5 and 11 are covered by default branch
          default:
            begin
              next_div = div + 8'd2;
              next_div_squared = div_squared + (div << 2) + 8'd4;
            end
        endcase

        if (next_div > div && next_div_squared > div_squared)
          next_state = NEXT_DIVISOR;
        else begin
          // Overflow
          next_state = ERROR;
          next_div = XW;
          next_div_squared = XW;
        end
      end

    default:
      begin
        next_state = 3'bx;
        next_res = XW;

        next_div = XW;
        next_div_squared = XW;
        next_div_go = 1'bx;

        next_addr = XA;
      end

  endcase
end

always @(posedge clk)
  if (rst) begin
    // Start by outputting the very first prime...
    state <= READY;
    res <= 1;

    res <= 1;
    ready <= 1;
    error <= 0;

    div <= XW;
    div_squared <= XW;
    div_go <= 0;

    addr <= XA;
    naddrs <= 0;
    write_en <= 0;
  end else begin
    state <= next_state;

    res <= next_res;
    ready <= next_ready;
    error <= next_error;

    div <= next_div;
    div_squared <= next_div_squared;
    div_go <= next_div_go;

    addr <= next_addr;
    naddrs <= next_naddrs;
    write_en <= next_write_en;
  end

`ifdef SIM
//  initial
//    $monitor("%t: clk=%b, go=%b, state=%h, res=%0d, addr=%0d, naddrs=%0d, write_en=%0d, div=%0d, div_squared=%0d, div_go=%b, rem=%0d, div_ready=%b", $time, clk, go, state, res, addr, naddrs, write_en, div, div_squared, div_go, rem, div_ready);
`endif

endmodule

