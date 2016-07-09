`include "defines.v"

module modulo #(
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
  output reg [WIDTH - 1:0] res
);

parameter HI = WIDTH - 1;
parameter XW = {WIDTH{1'bx}};
parameter X7 = 7'bx;

parameter READY = 2'd0;
parameter SUB   = 2'd1;
parameter ERROR = 2'd2;

reg [3:0] state;
reg go_prev;

/* This is nice but not supported by BLIF synthesis

function [7:0] msb;
  input [HI:0] x;
  reg [7:0] bit;
  integer i;
  begin
    bit = 0;
    // TODO: this could be done by splitting in halves on each iteration
    for (i = HI; i >= 0; i = i - 1)
      if (!bit && x[i])
        bit = i;
    msb = bit;
  end
endfunction

always @*
  msb_A <= msb(a);

*/

integer ia;
reg [7:0] msb_A;

always @* begin
  msb_A = 0;
  // TODO: this could be sped up by splitting in halves on each iteration
  for (ia = HI; ia >= 0; ia = ia - 1)
    if (!msb_A && a[ia])
      msb_A = ia;
end

integer ib;
reg [7:0] msb_B;

always @* begin
  msb_B = 0;
  for (ib = HI; ib >= 0; ib = ib - 1)
    if (!msb_B && b[ib])
      msb_B = ib;
end

wire [7:0] max_shift;
assign max_shift = (msb_A > msb_B + 1) ? (msb_A - msb_B - 1) : 0;

reg [HI:0] next_state;
reg [HI:0] next_A;
reg [HI:0] next_B;
reg [7:0] next_shift;
reg [HI:0] next_res;

always @* begin
  // FIXME: assign to prev. state instead?
  next_state = ERROR;
  next_A = XW;
  next_B = XW;
  next_shift = X7;

  next_res = res;

  if (go && !go_prev)
    if (b == 0) begin
      next_state = ERROR;
    end else begin
      next_state = SUB;
      next_A = a;
      next_B = b << max_shift;
      next_shift = max_shift;
    end
  else
    case (state)
      default:  // FIXME: undef for unknown states
        begin
          next_state = READY;
          next_A = A;
          next_B = B;
          next_shift = shift;
        end
      SUB:
        if (B <= A) begin
          next_state = state;
          next_A = A - B;
          next_B = B;
          next_shift = shift;
        end else if (B > A)
          if (shift > 0) begin
            // TODO: we can do faster than that by immediately shifting to next msb of A
            next_state = state;
            next_A = A;
            next_B = B >> 1;
            next_shift = shift - 1;
          end else begin
            `assert(shift, 0)
            next_state = READY;
            next_res = A;
          end
    endcase
end

// TODO: should I merge A with res? This reduces regcount but exposes internal
// details...
reg [HI:0] A;
reg [HI:0] B;
reg [7:0] shift;

always @(posedge clk)
  if (rst) begin
    // TODO: is it a good practice to explicitly undefine all things?
    // TODO: best approach to unify code snippets like this one?
    state <= READY;
    A <= XW;
    B <= XW;
    shift <= X7;
    go_prev <= 0;
    ready <= 1;
    error <= 0;
    res <= XW;
  end else begin
    state <= next_state;
    A <= next_A;
    B <= next_B;
    shift <= next_shift;
    go_prev <= go;
    ready = (next_state == READY || next_state == ERROR);
    error = (next_state == ERROR);
    res <= next_res;
  end

//  initial
//    $monitor("%t: go = %b, res = %h, state = %h, msb_A = %h, msb_B = %h, A = %h, B = %h, shift = %h", $time, go, res, state, msb_A, msb_B, A, B, shift);

endmodule

