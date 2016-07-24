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
alib bin/top
set worklib top
alog ../../src/primogen.v ../../src/divmod.v ../../src/prio_enc.v src/top.v
asim top
run 1000
endsim
quit
