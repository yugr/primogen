ICE_ROOT = /cygdrive/c/lscc/iCEcube2.2016.02
LM_LICENSE_FILE = $(ICE_ROOT)/license.dat

SYN_OUT = syn/primogen_Implmnt
LSE_OUT = rev_1

all: $(LSE_OUT)/sbt/outputs/bitmap/primogen_bitmap.bin
all: $(SYN_OUT)/sbt/outputs/bitmap/primogen_bitmap.bin

$(LSE_OUT)/sbt/outputs/bitmap/primogen_bitmap.bin: $(LSE_OUT)/primogen.edf
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl $(LSE_OUT)

$(LSE_OUT)/primogen.edf: $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$SYNTH_LSE -f syn/primogen_lse.prj
	test -f $@

$(SYN_OUT)/sbt/outputs/bitmap/primogen_bitmap.bin: $(SYN_OUT)/primogen.edf
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl $(SYN_OUT)

$(SYN_OUT)/primogen.edf: $(LM_LICENSE_FILE)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	rc=0
	$$SYNTH_SYN -prj syn/primogen_syn.prj || rc=$$?
	cat stdout.log
	test $$rc=0
	# Synplify does not know about error codes so check
	test -f $@

test:
	$$SIM  # TODO

clean:
	rm -rf $(SYN_OUT) $(LSE_OUT) *.ve xxx* stdout.log*

.ONESHELL:

.PHONY: all clean test

