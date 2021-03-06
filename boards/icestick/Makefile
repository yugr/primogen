$(shell mkdir -p bin)

# This may need to be changed for your environment
ICE_ROOT = /cygdrive/c/lscc/iCEcube2.2016.02

# Use Synplify by default
USE_LSE = 0

BLINK = bin/sbt/outputs/bitmap/blink_bitmap.bin
BENCH = bin/sbt/outputs/bitmap/bench_bitmap.bin
RAM_TEST = bin/sbt/outputs/bitmap/ram_test_bitmap.bin

all: $(BLINK) $(BENCH)

test:
	. ./set_vars.sh $(ICE_ROOT)
	$$SIM syn/sim.do

flash-%: syn/%_flash.xcf bin/sbt/outputs/bitmap/%_bitmap.bin
	. ./set_vars.sh $(ICE_ROOT)
	$$PROG -infile $< -logfile bin/$@.log

bitmap-blink: $(BLINK)
bitmap-bench: $(BENCH)
bitmap-ram_test: $(RAM_TEST)

bin/sbt/outputs/bitmap/%_bitmap.bin: bin/%.edf syn/icestick.pcf backend.tcl
	. ./set_vars.sh $(ICE_ROOT)
	rm -f $@
	$$TCL ./backend.tcl $*
	grep 'LUTs:' bin/sbt/outputs/packer/$*_pack.rpt
	grep 'Frequency:' bin/sbt/outputs/router/$*_timing.rpt

ifeq ($(USE_LSE), 1)
bin/%.edf: syn/%_lse.prj src/%.v src/ram*.v src/por.v src/clk_gen.v ../../src/*
	. ./set_vars.sh $(ICE_ROOT)
	rm -f $@
	$$LSE_SYN -f $<
	# Move all the generated trash to output dir
	mv .vdbs* *.v.ve *_prim.v *.arearep xxx_lse_* *.log *.twr bin
	# Synplify does not know about error codes so check
	test -f $@
else
bin/%.edf: syn/%_synp.prj src/%.v src/ram*.v src/por.v src/clk_gen.v ../../src/*
	. ./set_vars.sh $(ICE_ROOT)
	rm -f $@
	rc=0
	$$SYNP_SYN -prj $< || rc=$$?
	cat stdout.log
	test $$rc=0
	# Synplify does not know about error codes so check
	test -f $@
endif

clean:
	rm -rf bin

.ONESHELL:

.PRECIOUS: bin/%.edf bin/sbt/outputs/bitmap/%_bitmap.bin

.PHONY: all clean test

# Can't do this as it disables pattern rules above...
#.PHONY: flash-blink flash-bench bitmap-blink bitmap-bench

