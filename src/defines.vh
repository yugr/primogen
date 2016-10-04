`ifndef DEFINES_VH
`define DEFINES_VH

`ifdef synthesis
`ifdef SIM
SIM and synthesis should not be defined simultaneously
`endif
`endif

`define isunknown(sig) (^sig === 1'bx)

`ifdef SYNTHESIS
`ifdef SIM
SIM and SYNTHESIS should not be defined simultaneously
`endif
`endif

`ifdef SIM
`define assert(cond)                            \
  if ((cond) === 0)                             \
    $error("ASSERTION FAILED in %m: cond == 0")

`define assert_eq(sig, val)                       \
  if ((sig) !== (val))                            \
    $error("ASSERTION FAILED in %m: sig != val")

`define assert_ne(sig, val)                       \
  if ((sig) === (val))                            \
    $error("ASSERTION FAILED in %m: sig == val")

`define assert_lt(sig, val)                       \
  if (!((sig) < (val)))                           \
    $error("ASSERTION FAILED in %m: sig >= val")

`define assert_nox(sig)                             \
  if (^sig === 1'bx)                                \
    $error("ASSERTION FAILED in %m: sig undefined")

`define unreachable $error("UNREACHABLE in %m")

`else
`define assert(cond)
`define assert_eq(sig, val)
`define assert_lt(sig, val)
`define assert_nox(sig)
`define unreachable
`endif

`endif
