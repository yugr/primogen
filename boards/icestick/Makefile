$(shell mkdir -p bin)

# These may need to be changed for your environment
ICE_ROOT = /cygdrive/c/lscc/iCEcube2.2016.02
LM_LICENSE_FILE = $(ICE_ROOT)/license.dat

# Use Lattice tools by default
LSE_OR_SYNP = 1

BLINK = bin/sbt/outputs/bitmap/blink_bitmap.bin
BENCH = bin/sbt/outputs/bitmap/bench_bitmap.bin

all: $(BLINK) $(BENCH)

test:
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$SIM syn/sim.do

flash-%: syn/%_flash.xcf bin/sbt/outputs/bitmap/%_bitmap.bin
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$PROG -infile $< -logfile bin/$@.log

bitmap-%: bin/sbt/outputs/bitmap/%_bitmap.bin

bin/sbt/outputs/bitmap/%_bitmap.bin: bin/%.edf syn/icestick.pcf backend.tcl
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl $*

ifeq ($(LSE_OR_SYNP), 0)
bin/%.edf: syn/%_synp.prj src/%.v ../../src/*
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	rm -f $@
	rc=0
	$$SYNTH_SYN -prj $< || rc=$$?
	cat stdout.log
	test $$rc=0
	# Synplify does not know about error codes so check
	test -f $@
else
bin/%.edf: syn/%_lse.prj src/%.v ../../src/*
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	rm -f $@
	$$SYNTH_LSE -f $<
	# Move all the generated trash to output dir
	mv .vdbs* *.v.ve *_prim.v *.arearep xxx_lse_* *.log *.twr bin
	# Synplify does not know about error codes so check
	test -f $@
endif

clean:
	rm -rf bin

.ONESHELL:

.PRECIOUS: bin/%.edf bin/sbt/outputs/bitmap/%_bitmap.bin

.PHONY: all clean test

# Can't do this as it disables pattern rules above...
#.PHONY: flash-blink flash-bench bitmap-blink flash-bench

