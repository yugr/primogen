$(shell mkdir -p bin)

IVFLAGS = -Wall -Isrc
IVFLAGS_SIM = $(IVFLAGS) -DSIM
IVFLAGS_SYNTH = $(IVFLAGS) -tblif -Dsynthesis

all: bin/divrem_tb bin/primogen_tb bin/primogen_bench
all: bin/divrem.blif bin/prio_enc.blif
# all: bin/primogen.blif

bin/%: src/%.v
	iverilog $(IVFLAGS_SIM) -N$@.nl -o $@ $^

bin/divrem_tb: src/divrem.v src/prio_enc.v
bin/primogen_tb: src/primogen.v src/divrem.v src/prio_enc.v src/ram.v
bin/primogen_bench: src/primogen.v src/divrem.v src/prio_enc.v src/ram.v

bin/%.blif: src/%.v
	iverilog $(IVFLAGS_SYNTH) -o $@ $^

bin/divrem.blif: src/prio_enc.v
# bin/primogen.blif: src/divrem.v src/prio_enc.v

test: test-divrem test-primogen
bench: test-bench

test-%: bin/%_tb
	@vvp $<

test-bench: bin/primogen_bench
	@vvp $<

clean:
	rm -f bin/*

.PHONY: clean test all blif

