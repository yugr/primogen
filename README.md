# What is this?

Primogen is a toy prime number generator in Verilog which I write to
learn HW design.

It's mostly useless mainly because
* HW algorithms are not optimized
* found primes are not cached to avoid repetative work (like in
sieve of Eratosthenes)

Also in present state it probably violates all sane Verilog coding
guidelines.

# Run

Currently this only supports simulation and synthesis in Icarus
Verilog:
```
$ make all
$ make test
$ make blif
```
(for synthesis you may need sufficiently new Iverilog...).

# TODO

* port to iCEstick (both Lattice and Yosys toolchains)
* get code reviewed by professional designer and fix accordingly
* use [Fermat test](https://en.wikipedia.org/wiki/Fermat_primality_test) (and [quick exp](https://en.wikipedia.org/wiki/Modular_exponentiation))
* TODOs and FIXMEs in code
* teach Iverilog to synthesize encoder implemented with recursive functions (?)

