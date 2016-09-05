#!/bin/sh -e
# This file intentionally lacks executable perms
# (to force you to source it).

test $# = 1

ICE_ROOT=$1

CFG=$ICE_ROOT/config.xml

if ! test -f $CFG; then
  echo >&2 "Config file missing in $ICE_ROOT"
  exit 1
fi

LM_LICENSE_FILE=$(sed -ne '/LM_LICENSE_FILE/{ s/.*>\(.*\)<.*/\1/; p }' $CFG | tr '\' '/' )

if test -z "$LM_LICENSE_FILE"; then
  echo >&2 "Failed to find license info in $CFG"
  exit 1
fi

if ! test -f $LM_LICENSE_FILE; then
  echo >&2 "License file not found at $LM_LICENSE_FILE"
  exit 1
fi

if test -z "$LM_LICENSE_FILE"; then
  echo >&2 "TCL library info not found in $CFG"
  exit 1
fi

SYNTH_LSE=$ICE_ROOT/LSE/bin/nt/synthesis
test -x $LSE_SYNTH

SYNTH_SYN=$ICE_ROOT/sbt_backend/bin/win32/opt/synpwrap/synpwrap
test -x $SYN_SYNTH

SIM=$ICE_ROOT/Aldec/Active-HDL/BIN/VSimSA
test -x $SIM

PROG=$ICE_ROOT/../Programmer/3.7_x64/bin/nt64/pgrcmd

# Should be something like $ICE_ROOT/sbt_backend/bin/win32/lib/tcl8.4
export TCL_LIBRARY=$(sed -ne '/TCL_LIBRARY/ { s!.*>\(.*\)<.*!\1!; s!\$(RootPath)!'$ICE_ROOT'!; p }' $CFG)

# We need any Windows TCL here (Cygwin's TCL will not work)
TCL=$ICE_ROOT/Aldec/Active-HDL/BIN/tclsh85
test -x $TCL

# These variables need to be set for Lattice tools
export FOUNDRY=$ICE_ROOT/LSE
export LM_LICENSE_FILE=$LM_LICENSE_FILE
export PLATFORM=MCD
export SBT_DIR=$ICE_ROOT/sbt_backend
export SYNPLIFY_PATH=$ICE_ROOT/synpbase

if test $(uname -o) = Cygwin; then
  for v in FOUNDRY LM_LICENSE_FILE SBT_DIR SYNPLIFY_PATH TCL_LIBRARY; do
    eval "$v=\`cygpath -w \$$v\`"
  done
fi

