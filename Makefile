$(shell mkdir -p bin)

IVFLAGS = -Wall -Isrc
IVFLAGS_SYNTH = $(IVFLAGS) -tblif -Dsynthesis

all: bin/divmod_tb bin/primogen_tb
all: bin/divmod.blif bin/primogen.blif bin/prio_enc.blif

bin/%_tb: src/%.v src/%_tb.v
	iverilog $(IVFLAGS) -N$@.nl -o $@ $^

bin/divmod_tb: src/prio_enc.v
bin/primogen_tb: src/divmod.v src/prio_enc.v

bin/%.blif: src/%.v
	iverilog $(IVFLAGS_SYNTH) -o $@ $^

bin/divmod.blif: src/prio_enc.v
bin/primogen.blif: src/divmod.v src/prio_enc.v

test: test-divmod test-primogen

test-%: bin/%_tb
	@vvp $<
	@echo "$@ PASSED"

clean:
	rm -f bin/*

.PHONY: clean test all blif

