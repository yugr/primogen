# What is this?

Primogen is a toy prime number generator in Verilog which I write to
learn HW design.

It's mostly useless mainly because
* HW algorithms are not optimized
* found primes are not cached to avoid repetative work (like in
sieve of Eratosthenes)

Also in present state it may violate Verilog coding practices.

# Run

To simulate and synthesize via Icarus, run
```
$ make all
$ make test
```
(for synthesis you may need sufficiently new version...).

To generate code for iCEstick, do
```
$ cd boards/icestick
$ make all
```
This will generate bitmap using Lattice synthsizer and
default backend flow (for Synplify synthesizer, set
LSE\_OR\_SYNP to 0).

To flash generated bitmap to device, do
```
$ make flash
```
I haven't been able to get this to work for my board though.

To simulate via Active-HDL (which comes with iCEcube):
```
$ make test
```

# TODO

* run on iCEstick
* port to iCEstick Yosys toolchain
* get code reviewed by more professional designers and fix accordingly
* use [Fermat test](https://en.wikipedia.org/wiki/Fermat_primality_test) (and [quick exp](https://en.wikipedia.org/wiki/Modular_exponentiation))
* TODOs and FIXMEs in code

