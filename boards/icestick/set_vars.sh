#!/bin/sh -e

test $# = 2

ICE_ROOT=$1
LM_LICENSE_FILE=$2

if ! test -f $LM_LICENSE_FILE; then
  echo >&2 "License file not found at $LM_LICENSE_FILE (need to update LM_LICENSE_FILE env. var.?)"
  exit 1
fi

SYNTH_LSE=$ICE_ROOT/LSE/bin/nt/synthesis
test -x $LSE_SYNTH

SYNTH_SYN=$ICE_ROOT/sbt_backend/bin/win32/opt/synpwrap/synpwrap
test -x $SYN_SYNTH

SIM=$ICE_ROOT/Aldec/Active-HDL/BIN/VSimSA
test -x $SIM

PROG=$ICE_ROOT/../Programmer/3.7_x64/bin/nt64/pgrcmd

# We need any Windows TCL here (Cygwin's TCL will not work)
TCL=$ICE_ROOT/Aldec/Active-HDL/BIN/tclsh85
test -x $TCL

# These variables need to be set for Lattice tools
export FOUNDRY=$ICE_ROOT/LSE
export LM_LICENSE_FILE=$LM_LICENSE_FILE
export PLATFORM=MCD
export SBT_DIR=$ICE_ROOT/sbt_backend
export SYNPLIFY_PATH=$ICE_ROOT/synpbase
export TCL_LIBRARY=$ICE_ROOT/sbt_backend/bin/win32/lib/tcl8.4

if test $(uname -o) = Cygwin; then
  for v in FOUNDRY LM_LICENSE_FILE SBT_DIR SYNPLIFY_PATH TCL_LIBRARY; do
    eval "$v=\`cygpath -w \$$v\`"
  done
fi

