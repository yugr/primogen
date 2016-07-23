ICE_ROOT = /cygdrive/c/lscc/iCEcube2.2016.02
LM_LICENSE_FILE = $(ICE_ROOT)/license.dat

DEPS = $(wildcard ../../src/*) src/* syn/*.pcf $(LM_LICENSE_FILE)

all: lse syn

test:
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$SIM syn/sim.do

lse: lse_out/sbt/outputs/bitmap/top_bitmap.bin

lse_out/sbt/outputs/bitmap/top_bitmap.bin: lse_out/top.edf
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl lse_out

lse_out/top.edf: syn/primogen_lse.prj $(DEPS)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$SYNTH_LSE -f $<
	test -f $@

syn: synp_out/sbt/outputs/bitmap/top_bitmap.bin

synp_out/sbt/outputs/bitmap/top_bitmap.bin: synp_out/top.edf
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	$$TCL ./backend.tcl synp_out

synp_out/top.edf: syn/primogen_syn.prj $(DEPS)
	. ./set_vars.sh $(ICE_ROOT) $(LM_LICENSE_FILE)
	rc=0
	$$SYNTH_SYN -prj $< || rc=$$?
	cat stdout.log
	test $$rc=0
	# Synplify does not know about error codes so check
	test -f $@

clean:
	rm -rf synp_out lse_out ahdl_out ahdl
	rm -f *.ve xxx* stdout.log* *.arearep *.twr *_drc.log *_prim.v

.ONESHELL:

.PHONY: all clean test lse syn

