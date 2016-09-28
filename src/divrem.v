`include "defines.vh"

module divrem #(
  parameter WIDTH_LOG = 4
) (clk, go, rst, num, den, ready, error, quot, rem);

localparam WIDTH = 1 << WIDTH_LOG;
localparam HI = WIDTH - 1;

input clk;
input go;
input rst;
input [HI:0] num;
input [HI:0] den;
output reg ready;
output reg error;
output reg [HI:0] quot;
output reg [HI:0] rem;

localparam XW = {WIDTH{1'bx}};
localparam X7 = 7'bx;

localparam READY = 2'd0;
localparam SUBTRACT = 2'd1;
localparam ERROR = 2'd2;

reg [1:0] next_state;
reg [HI:0] next_quot;
reg [HI:0] next_rem;

wire next_ready;
wire next_error;

reg [1:0] state;

wire [HI:0] a;
wire [HI:0] sub;
wire [WIDTH_LOG - 1:0] rem_msb;
wire [WIDTH_LOG - 1:0] den_msb;
wire [WIDTH_LOG - 1:0] shift;

// TODO: pipeline this to increase freq?
prio_enc #(.WIDTH_LOG(WIDTH_LOG)) num_pe(.x(a), .msb(rem_msb));
prio_enc #(.WIDTH_LOG(WIDTH_LOG)) den_pe(.x(den), .msb(den_msb));

assign a = state == READY || state == ERROR ? num : rem;

assign shift = rem_msb > den_msb ? (rem_msb - den_msb - 8'b1) : 8'b0;

assign sub = den << shift;

assign next_ready = next_state == READY || next_state == ERROR;
assign next_error = next_state == ERROR;

always @* begin
  next_state = state;
  next_quot = quot;
  next_rem = rem;

  case (state)
    READY, ERROR:
      if (go) begin
        if (den == 0) begin
          next_state = ERROR;
          next_quot = XW;
          next_rem = XW;
        end else begin
          next_state = SUBTRACT;
          next_quot = 0;
          next_rem = num;
        end
      end else begin
        // Stay in READY and do nothing
      end

    SUBTRACT:
      if (sub <= rem) begin
        next_quot = quot + (1'd1 << shift);
        next_rem = rem - sub;
      end else begin
        next_state = READY;
      end
  endcase
end

always @(posedge clk)
  if (rst) begin
    // TODO: is it a good practice to explicitly undefine everything?
    state <= READY;
    quot <= XW;
    rem <= XW;
    ready <= 1;
    error <= 0;
  end else begin
    state <= next_state;
    quot <= next_quot;
    rem <= next_rem;
    ready <= next_ready;
    error <= next_error;
  end

`ifdef SIM
reg [HI:0] ready_prev;
reg [HI:0] go_r;
reg [HI:0] go_prev;
reg [HI:0] num_prev;
reg [HI:0] den_prev;

always @(posedge clk) begin
  ready_prev <= ready;
  go_r <= go;
  go_prev <= go_r;
  num_prev <= num;
  den_prev <= den;

  // Precondition: core signals must always be valid
  `assert_nox(rst);
  `assert_nox(clk);

  if (!rst) begin
    // Precondition: if 'go' is asserted, other inputs are valid
    if (go) begin
      `assert_nox(num);
      `assert_nox(den);
    end

    // Precondition: inputs are stable until computation is over
    if (!ready) begin
      `assert_eq(num, num_prev);
      `assert_eq(den, den_prev);
    end

    // Precondition: 'go' is not re-asserted until computation is finished
    // (this won't be a bug but would be ignored and is likely to indicate
    // incorrect usage of module).
    if (!ready)
      `assert(!(go && !go_prev));

    // Invariant: priority encoder produces defined results
    if (!`isunknown(den))
      `assert_nox(den_msb);
    if (!`isunknown(rem))
      `assert_nox(rem_msb);

    // Postcondition: outputs are correct
    if (ready && !ready_prev && !error) begin
      `assert_lt(rem, den);
      `assert_eq(den*quot + rem, num);
    end
  end
end
`endif

`ifdef SIM
//  initial
//    $monitor("%t: go=%h, num=%0d, den=%0d, quot=%h, rem=%0d, a=%0d, state=%h, rem_msb=%h, den_msb=%h, sub=%0d, shift=%h, ready=%h", $time, go, num, den, quot, rem, a, state, rem_msb, den_msb, sub, shift, ready);
`endif

endmodule

