$(shell mkdir -p bin)

# These may need to be changed for your environment
ICE_ROOT = /cygdrive/c/lscc/iCEcube2.2016.02
LM_LICENSE_FILE = $(ICE_ROOT)/license.dat

# Use Lattice tools by default
LSE_OR_SYNP = 1

BITMAP = bin/sbt/outputs/bitmap/top_bitmap.bin

all: $(BITMAP)

test: $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$SIM syn/sim.do

flash: syn/flash.xcf $(BITMAP) $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$PROG -infile $< -logfile bin/flash.log

$(BITMAP): bin/top.edf syn/icestick.pcf $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl bin

bin/top.edf: ../../src/* src/* syn/* $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
ifeq ($(LSE_OR_SYNP), 0)
	rc=0
	$$SYNTH_SYN -prj syn/synp.prj || rc=$$?
	cat stdout.log
	test $$rc=0
else
	$$SYNTH_LSE -f syn/lse.prj
	# Move all the generated trash to output dir
	mv .vdbs* *.v.ve *_prim.v *.arearep xxx_lse_* *.log *.twr bin
endif
	# Synplify does not know about error codes so check
	test -f $@

clean:
	rm -rf bin

.ONESHELL:

.PHONY: all clean test flash

