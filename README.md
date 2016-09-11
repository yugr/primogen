# What is this?

Primogen is a toy prime number generator in Verilog which I wrote to
learn HW design.

It's mostly useless, mainly because the simplest math and HW algorithms
are used. Also in present state it may violate common Verilog coding
practices.

For now, this has only been tested on Cygwin but porting to Linux
should be straightforward.

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

To flash generated bitmaps to device, do
```
$ make flash-$BITMAP
```

$BITMAP can be either _blink_ (computes new prime every
5 seconds and displays it's least-significant bits on LEDs)
or _bench_ (computes all 16-bit primes and lits green LED when
done).

Above instructions will use Synplify (you may need to
customize ICE\_ROOT variable for your environment).

To use Lattice synthesizer, set USE\_LSE to 1.
To use Yosys toolchain, append `-f Makefile.yosys`
to make invocation.

Finally, to simulate via Active-HDL (which comes
with iCEcube):
```
$ make test
```

# TODO

* fix Yosys build
* get code reviewed by more professional designers and fix accordingly
* add UART output
* use [Fermat test](https://en.wikipedia.org/wiki/Fermat_primality_test) (and [quick exp](https://en.wikipedia.org/wiki/Modular_exponentiation))
* automatically explore synthesis options to generate more efficient design
* TODOs and FIXMEs in code

