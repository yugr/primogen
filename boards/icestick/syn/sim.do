alib ahdl-out/divmod
set worklib divmod
alog ../../src/divmod.v ../../src/prio_enc.v ../../src/divmod_tb.v
asim divmod_tb
run
endsim
alib ahdl-out/primogen
set worklib primogen
alog ../../src/primogen.v ../../src/divmod.v ../../src/prio_enc.v ../../src/primogen_tb.v
asim primogen_tb
run
endsim
quit
