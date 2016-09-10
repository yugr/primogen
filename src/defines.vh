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
`define assert(sig, val)                                \
  if ((sig) !== val)                                    \
    begin                                               \
      $display("ASSERTION FAILED in %m: (sig) != val"); \
      $finish(1);                                       \
    end
`define unreachable begin          \
    $display("UNREACHABLE in %m"); \
    $finish(1);                    \
  end
`define mark begin                 \
    $display("Line %d", __LINE__); \
  end
`else
`define assert(sig, val) ;
`define unreachable ;
`define mark ;
`endif

