`ifdef synthesis
`ifdef SIM
SIM and synthesis should not be defined simultaneously
`endif
`endif

`ifdef SYNTHESIS
`ifdef SIM
SIM and SYNTHESIS should not be defined simultaneously
`endif
`endif

`ifdef SIM
`define assert_eq(sig, val)                       \
  if ((sig) !== (val))                            \
    $error("ASSERTION FAILED in %m: sig != val")

`define assert_lt(sig, val)                       \
  if (!((sig) < (val)))                           \
    $error("ASSERTION FAILED in %m: sig >= val")

`define assert_nox(sig)                             \
  if (^sig === 1'bx)                                \
    $error("ASSERTION FAILED in %m: sig undefined")

`define unreachable $error("UNREACHABLE in %m")

`else
`define assert_eq(sig, val)
`define assert_lt(sig, val)
`define assert_nox(sig)
`define unreachable
`endif

