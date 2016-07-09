$(shell mkdir -p bin)

IVFLAGS = -Wall -Isrc
IVFLAGS_SYNTH = $(IVFLAGS) -tblif -DSYNTH

all: bin/modulo_tb bin/primogen_tb

blif: bin/modulo.blif bin/primogen.blif

bin/%_tb: src/%.v src/%_tb.v
	iverilog $(IVFLAGS) -N$@.nl -o $@ $^

bin/primogen_tb: src/modulo.v

bin/%.blif: src/%.v
	iverilog $(IVFLAGS_SYNTH) -o $@ $^

bin/primogen.blif: src/modulo.v

test: test-modulo test-primogen

test-%: bin/%_tb
	@vvp $<
	@echo "$@ PASSED"

clean:
	rm -f bin/*

.PHONY: clean test all blif

