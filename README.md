# What is this?

Primogen is a toy prime number generator in Verilog which I wrote to
learn HW design.

It's mostly useless, mainly because
* HW algorithms are not optimized
* found primes are not cached to avoid repetative work (like in
sieve of Eratosthenes)

Also in present state it may violate common Verilog coding practices.

# Run

To simulate and synthesize via Icarus, run
```
$ make all
$ make test
```
(for synthesis you may need sufficiently new version...).

# Run on iCEstick

To generate code for iCEstick, do
```
$ cd boards/icestick
$ make all
```
This will generate bitmaps using Lattice synthsizer and
default backend flow (for Synplify synthesizer, set
LSE\_OR\_SYNP to 0). To use Yosys toolchain, append
`-f Makefile.yosys` to make invocation.

To flash generated bitmaps to device, do
```
$ make flash-$BITMAP
```

$BITMAP can be either _blink_ (computes new prime every
5 seconds and displays it's least-significant bits on LEDs)
or _bench_ (computes 16-bit primes and lits green LED when
done).

To simulate via Active-HDL (which comes with iCEcube):
```
$ make test
```

# TODO

* port to iCEstick Yosys toolchain
* get code reviewed by more professional designers and fix accordingly
* use [Fermat test](https://en.wikipedia.org/wiki/Fermat_primality_test) (and [quick exp](https://en.wikipedia.org/wiki/Modular_exponentiation))
* utilize onboard RAM to implement Eratosthenes sieve (?)
* automatically explore synthesis options to generate more efficient design
* TODOs and FIXMEs in code

