$(shell mkdir -p bin)

IVFLAGS = -Wall -Isrc
IVFLAGS_SIM = $(IVFLAGS) -DSIM
IVFLAGS_SYNTH = $(IVFLAGS) -tblif -Dsynthesis

all: bin/divrem_tb bin/primogen_tb
all: bin/divrem.blif bin/prio_enc.blif
# all: bin/primogen.blif

bin/%_tb: src/%.v src/%_tb.v
	iverilog $(IVFLAGS_SIM) -N$@.nl -o $@ $^

bin/divrem_tb: src/prio_enc.v
bin/primogen_tb: src/divrem.v src/prio_enc.v src/ram.v

bin/%.blif: src/%.v
	iverilog $(IVFLAGS_SYNTH) -o $@ $^

bin/divrem.blif: src/prio_enc.v
# bin/primogen.blif: src/divrem.v src/prio_enc.v

test: test-divrem test-primogen

test-%: bin/%_tb
	@vvp $<

clean:
	rm -f bin/*

.PHONY: clean test all blif

