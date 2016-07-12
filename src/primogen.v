`include "defines.vh"

module primegen #(
  parameter WIDTH_LOG = 4
) (
  input clk,
  input go,
  input rst,
  // TODO: input [WIDTH - 1:0] from
  output reg ready,
  output reg error,
  output reg [(1 << WIDTH_LOG) - 1:0] res
);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

localparam XW = {WIDTH{1'bx}};
localparam X7 = 7'bx;

localparam READY = 3'd0;
localparam ERROR = 3'd1;
localparam CHECK_DIVS = 3'd2;
localparam WAIT_MOD_DLY = 3'd3;
localparam WAIT_MOD = 3'd4;

reg go_prev;

wire mod_ready;
wire mod_error;
wire [HI:0] mod_res;

// TODO: is Verilog guaranteed to translate these into comb. logic?
reg [2:0] next_state;
reg [HI:0] next_p;
reg [HI:0] next_div;
reg [HI:0] next_div_squared;
reg next_mod_go;
reg [HI:0] next_res;

always @* begin
  next_state = state;
  next_p = p;
  next_div = div;
  next_div_squared = div_squared;
  next_res = res;

  next_mod_go = 0;

  if (go && !go_prev) begin
    // Search for next prime
    next_state = CHECK_DIVS;
    // next_p = res + 1;
    case (res)
      1: next_p = 2;
      2: next_p = 3;
      default: next_p = res + 2;
    endcase
    next_div = 2;
    next_div_squared = 4;
  end else
    case (state)
      CHECK_DIVS:
        if (div_squared > p) begin
          // None of potential divisors matched => number is prime!
          next_state = READY;
          next_res = p;
        end else begin
          next_state = WAIT_MOD_DLY;
          next_mod_go = 1;
        end
      WAIT_MOD_DLY:
        begin
          // This state gives modulo calculator time to reset ready bit.
          // TODO: not sure it's the best approach...
          next_state = WAIT_MOD;
        end
      WAIT_MOD:
        if (mod_error) begin
          next_state = ERROR;
        end else if (mod_ready) begin
          // Modulo is ready for inspection
          next_state = CHECK_DIVS;
          if (mod_res == 0) begin
            // Divisable => abort and try next candidate
            // next_p = p + 1;
            next_p = p + 2;
            next_div = 2;
            next_div_squared = 4;
          end else begin
            // Not divisable => try next divisor
            // next_div_squared = div_squared + (div << 2) + 4;
            // next_div = div + 1;
            case (div)
              2:
                begin
                  next_div = 3;
                  next_div_squared = 9;
                end
              7:
                begin
                  next_div = 11;
                  next_div_squared = 121;
                end
              13:
                begin
                  next_div = 17;
                  next_div_squared = 289;
                end
              default:
                begin
                  next_div = div + 2; // Also works for 3, 5, 11 and 17
                  next_div_squared = div_squared + (div << 2) + 4;
                end
            endcase
          end
        end else
          ; // Keep waiting
    endcase
end

reg [2:0] state;
reg [HI:0] p;
reg [HI:0] div;
reg [HI:0] div_squared;
reg mod_go;

divmod #(.WIDTH_LOG(WIDTH_LOG)) d_m(
  .clk(clk),
  .go(mod_go),
  .rst(rst),
  .a(p),
  .b(div),
  .ready(mod_ready),
  .error(mod_error),
  .mod(mod_res));

always @(posedge clk)
  if (rst) begin
    // Start by outputting the very first prime...
    state <= READY;
    p <= XW;
    div <= XW;
    div_squared <= XW;
    mod_go <= 0;
    go_prev <= 0;
    ready <= 1;
    error <= 0;
    res <= 1;
  end else begin
    state <= next_state;
    p <= next_p;
    div <= next_div;
    div_squared <= next_div_squared;
    mod_go <= next_mod_go;
    go_prev <= go;
    ready <= (next_state == READY || next_state == ERROR);
    error <= (next_state == ERROR);
    res <= next_res;
  end

//  initial
//    $monitor("%t: rst=%b, go=%b, res=%h, state=%h, p=%h, div=%h, div_squared=%h, mod_error=%b, mod_go=%b, mod_res=%h, mod_ready=%b", $time, rst, go, res, state, p, div, div_squared, mod_error, mod_go, mod_res, mod_ready);

endmodule

