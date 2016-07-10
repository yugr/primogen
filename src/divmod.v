`include "defines.v"

module divmod #(
  parameter WIDTH = 16
) (
  input clk,
  input go,
  input rst,
  // TODO: can I somehow use the HI definition from below?
  input [WIDTH - 1:0] a,
  input [WIDTH - 1:0] b,
  output reg ready,
  output reg error,
  output reg [WIDTH - 1:0] div,
  output reg [WIDTH - 1:0] mod
);

parameter HI = WIDTH - 1;
parameter XW = {WIDTH{1'bx}};
parameter X7 = 7'bx;

parameter READY = 2'd0;
parameter SUBTRACT   = 2'd1;
parameter ERROR = 2'd2;

reg [3:0] state;
reg go_prev;

wire [7:0] a_msb;
prio_enc a_pe(.x(a), .msb(a_msb));

wire [7:0] b_msb;
prio_enc b_pe(.x(b), .msb(b_msb));

wire [7:0] max_shift;
assign max_shift = (a_msb > b_msb + 1) ? (a_msb - b_msb - 1) : 0;

reg [HI:0] next_state;
reg [HI:0] next_sub;
reg [7:0] next_shift;
reg [HI:0] next_div;
reg [HI:0] next_mod;

always @* begin
  // FIXME: assign to prev. state instead?
  next_state = ERROR;
  next_sub = XW;
  next_shift = X7;

  next_div = div;
  next_mod = mod;

  if (go && !go_prev)
    if (b == 0) begin
      next_state = ERROR;
    end else begin
      next_state = SUBTRACT;
      next_div = 0;
      next_mod = a;
      next_sub = b << max_shift;
      next_shift = max_shift;
    end
  else
    case (state)
      default:  // FIXME: undef for unknown states
        begin
          next_state = READY;
          next_sub = sub;
          next_shift = shift;
        end
      SUBTRACT:
        if (sub <= mod) begin
          next_state = state;
          next_div = div + (1 << shift);
          next_mod = mod - sub;
          next_sub = sub;
          next_shift = shift;
        end else if (sub > mod)
          if (shift > 0) begin
            // TODO: we can do faster than that by immediately shifting to next msb of A
            next_state = state;
            next_sub = sub >> 1;
            next_shift = shift - 1;
          end else begin
            `assert(shift, 0)
            next_state = READY;
          end
    endcase
end

// TODO: should I merge A with res? This reduces regcount but exposes internal
// details...
reg [HI:0] sub;
reg [7:0] shift;

always @(posedge clk)
  if (rst) begin
    // TODO: is it a good practice to explicitly undefine all things?
    // TODO: best approach to unify code snippets like this one?
    state <= READY;
    mod <= XW;
    div <= XW;
    sub <= XW;
    shift <= X7;
    go_prev <= 0;
    ready <= 1;
    error <= 0;
  end else begin
    state <= next_state;
    mod <= next_mod;
    div <= next_div;
    sub <= next_sub;
    shift <= next_shift;
    go_prev <= go;
    ready = (next_state == READY || next_state == ERROR);
    error = (next_state == ERROR);
  end

//  initial
//    $monitor("%t: go = %b, res = %h, state = %h, a_msb = %h, b_msb = %h, A = %h, B = %h, shift = %h", $time, go, res, state, a_msb, b_msb, A, B, shift);

endmodule

