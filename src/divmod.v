`include "defines.vh"

module divmod #(
  parameter WIDTH_LOG = 4
) (
  input clk,
  input go,
  input rst,
  // TODO: can I somehow use the HI definition from below?
  input [(1 << WIDTH_LOG) - 1:0] a,
  input [(1 << WIDTH_LOG) - 1:0] b,
  output reg ready,
  output reg error,
  output reg [(1 << WIDTH_LOG) - 1:0] rem,
  output reg [(1 << WIDTH_LOG) - 1:0] quot
);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

localparam XW = {WIDTH{1'bx}};
localparam X7 = 7'bx;

localparam READY = 2'd0;
localparam SUBTRACT   = 2'd1;
localparam ERROR = 2'd2;

reg [1:0] state;
reg [HI:0] sub;
reg [7:0] shift;

reg [1:0] next_state;
reg [HI:0] next_sub;
reg [7:0] next_shift;
reg [HI:0] next_rem;
reg [HI:0] next_quot;

wire next_ready;
wire next_error;

wire [7:0] a_msb;
wire [7:0] b_msb;
wire [7:0] max_shift;

prio_enc #(.WIDTH_LOG(WIDTH_LOG)) a_pe(.x(a), .msb(a_msb));
prio_enc #(.WIDTH_LOG(WIDTH_LOG)) b_pe(.x(b), .msb(b_msb));

assign max_shift = (a_msb > b_msb + 8'b1) ? (a_msb - b_msb - 8'b1) : 8'b0;

assign next_ready = next_state == READY || next_state == ERROR;
assign next_error = next_state == ERROR;

always @* begin
  next_state = state;
  next_sub = sub;
  next_shift = shift;
  next_rem = rem;
  next_quot = quot;

  case (state)
    READY, ERROR:
      if (go) begin
        if (b == 0) begin
          next_state = ERROR;
          next_sub = XW;
          next_shift = X7;
          next_rem = XW;
          next_quot = XW;
        end else begin
          next_state = SUBTRACT;
          next_sub = b << max_shift;
          next_shift = max_shift;
          next_rem = 0;
          next_quot = a;
        end
      end else begin
        // Stay in READY and do nothing
      end

    SUBTRACT:
      if (sub <= quot) begin
        next_rem = rem + (1'd1 << shift);
        next_quot = quot - sub;
      end else if (shift > 0) begin  // sub > quot
        // TODO: we can do faster than that by immediately shifting to next msb of A
        next_sub = sub >> 1'd1;
        next_shift = shift - 1'd1;
      end else begin
        next_state = READY;
        next_sub = XW;
        next_shift = X7;
      end

    default:
      begin
        next_state = 2'bx;
        next_sub = XW;
        next_shift = X7;
        next_rem = XW;
        next_quot = XW;
      end

  endcase
end

always @(posedge clk)
  if (rst) begin
    // TODO: is it a good practice to explicitly undefine all things?
    // TODO: best approach to unify code snippets like this one?
    state <= READY;
    sub <= XW;
    shift <= X7;
    quot <= XW;
    rem <= XW;
    ready <= 1;
    error <= 0;
  end else begin
    state <= next_state;
    sub <= next_sub;
    shift <= next_shift;
    quot <= next_quot;
    rem <= next_rem;
    ready <= next_ready;
    error <= next_error;
  end

//  initial
//    $monitor("%t: go=%b, a=%h, b=%h, quot=%h, state=%h, a_msb=%h, b_msb=%h, sub=%h, shift=%h, ready=%b", $time, go, a, b, quot, state, a_msb, b_msb, sub, shift, ready);

endmodule

