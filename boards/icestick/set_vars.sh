#!/bin/sh -e

ICE_ROOT=$1
LM_LICENSE_FILE=$2

if ! test -f $LM_LICENSE_FILE; then
  echo >&2 "License file not found at $LM_LICENSE_FILE (need to update LM_LICENSE_FILE env. var.?)"
  exit 1
fi

SYNTH_LSE=$ICE_ROOT/LSE/bin/nt/synthesis.exe
test -x $LSE_SYNTH

SYNTH_SYN=$ICE_ROOT/sbt_backend/bin/win32/opt/synpwrap/synpwrap.exe
test -x $SYN_SYNTH

SIM=$ICE_ROOT/Aldec/Active-HDL/BIN/VSimSA.exe
test -x $SIM

# We need any Windows TCL here (Cygwin's TCL will not work)
TCL=$ICE_ROOT/Aldec/Active-HDL/BIN/tclsh85.exe
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

