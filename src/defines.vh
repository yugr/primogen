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
`define assert_eq(sig, val)                             \
  if ((sig) !== (val))                                  \
    begin                                               \
      $display("ASSERTION FAILED in %m: (sig) != val"); \
      $finish(1);                                       \
    end
`define assert_lt(sig, val)                             \
  if (!((sig) < (val)))                                 \
    begin                                               \
      $display("ASSERTION FAILED in %m: (sig) >= val"); \
      $finish(1);                                       \
    end
`define unreachable begin          \
    $display("UNREACHABLE in %m"); \
    $finish(1);                    \
  end
`else
`define assert_eq(sig, val) ;
`define assert_lt(sig, val) ;
`define unreachable ;
`endif

