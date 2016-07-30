alib bin/divmod
set worklib divmod
alog ../../src/divmod.v ../../src/prio_enc.v ../../src/divmod_tb.v
asim divmod_tb
run
endsim
alib bin/primogen
set worklib primogen
alog ../../src/primogen.v ../../src/divmod.v ../../src/prio_enc.v ../../src/primogen_tb.v
asim primogen_tb
run
endsim
alib bin/blink
set worklib blink
alog ../../src/primogen.v ../../src/divmod.v ../../src/prio_enc.v src/blink.v
asim blink
run 1000
endsim
quit
