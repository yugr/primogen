alib bin/divrem
set worklib divrem
alog +define+SIM ../../src/divrem.v ../../src/prio_enc.v ../../src/por.v ../../src/divrem_tb.v
asim divrem_tb
run
endsim
alib bin/primogen
set worklib primogen
alog +define+SIM ../../src/primogen.v ../../src/divrem.v ../../src/prio_enc.v ../../src/ram.v ../../src/por.v ../../src/primogen_tb.v
asim primogen_tb
run
endsim
alib bin/blink
set worklib blink
alog +define+SIM ../../src/primogen.v ../../src/divrem.v ../../src/prio_enc.v ../../src/ram.v src/por.v src/blink.v
asim blink
run 1000
endsim
quit
