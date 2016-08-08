`ifndef synthesis
`ifndef SYNTHESIS
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
`endif
`endif

`ifndef assert
`define assert(sig, val) ;
`define unreachable ;
`define mark ;
`endif

