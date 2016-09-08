alib bin/divrem
set worklib divrem
alog ../../src/divrem.v ../../src/prio_enc.v ../../src/divrem_tb.v
asim divrem_tb
run
endsim
alib bin/primogen
set worklib primogen
alog ../../src/primogen.v ../../src/divrem.v ../../src/prio_enc.v ../../src/primogen_tb.v
asim primogen_tb
run
endsim
alib bin/blink
set worklib blink
alog ../../src/primogen.v ../../src/divrem.v ../../src/prio_enc.v src/blink.v
asim blink
run 1000
endsim
quit
