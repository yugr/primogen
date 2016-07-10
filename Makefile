$(shell mkdir -p bin)

IVFLAGS = -Wall -Isrc
IVFLAGS_SYNTH = $(IVFLAGS) -tblif -DSYNTH

all: bin/divmod_tb bin/primogen_tb

blif: bin/divmod.blif bin/primogen.blif

bin/%_tb: src/%.v src/%_tb.v
	iverilog $(IVFLAGS) -N$@.nl -o $@ $^

bin/primogen_tb: src/divmod.v

bin/%.blif: src/%.v
	iverilog $(IVFLAGS_SYNTH) -o $@ $^

bin/primogen.blif: src/divmod.v

test: test-divmod test-primogen

test-%: bin/%_tb
	@vvp $<
	@echo "$@ PASSED"

clean:
	rm -f bin/*

.PHONY: clean test all blif

