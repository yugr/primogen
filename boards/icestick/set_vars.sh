#!/bin/sh -e
# This file intentionally lacks executable perms
# (to force you to source it).

if test $# != 1; then
  echo >&2 "Syntax: source set_vars.sh ICE_ROOT"
  exit 1
fi

ICE_ROOT=$1

CFG=$ICE_ROOT/config.xml

if ! test -f $CFG; then
  echo >&2 "Config file missing in $ICE_ROOT"
  exit 1
fi

# From this we'll get LM_LICENSE_FILE, SBT_DIR and TCL_LIBRARY
for var in $(sed -ne '/<Environment>/,/<\/Environment>/{ />.*</{ s!.*<\([A-Za-z_0-9]\+\).*>\(.*\)<.*!\1=\2! ; s!\$(RootPath)!'$ICE_ROOT'! ; p } }' $CFG | tr '\' '/'); do
  eval "export $var"
done

if test -z "$LM_LICENSE_FILE" -o -z "$TCL_LIBRARY" -o -z "$SBT_DIR"; then
  echo >&2 "Failed to parse $CFG"
  exit 1
fi

# Other variables that need to be set for Lattice tools
export FOUNDRY=$ICE_ROOT/LSE
export SYNPLIFY_PATH=$ICE_ROOT/synpbase
#export PLATFORM=MCD

if test $(uname -o) = Cygwin; then
  for v in FOUNDRY LM_LICENSE_FILE SBT_DIR SYNPLIFY_PATH TCL_LIBRARY; do
    eval "$v=\`cygpath -w \$$v\`"
  done
fi

# Tool paths (for Makefile)

SYNTH_LSE=$ICE_ROOT/LSE/bin/nt/synthesis
if ! test -x $SYNTH_LSE; then
  echo >&2 "Lattice synthesizer not found in $SYNTH_LSE"
  exit 1
fi

SYNTH_SYN=$ICE_ROOT/sbt_backend/bin/win32/opt/synpwrap/synpwrap
if ! test -x $SYNTH_SYN; then
  echo >&2 "Synplify not found in $SYNTH_SYN"
  exit 1
fi

SIM=$ICE_ROOT/Aldec/Active-HDL/BIN/VSimSA
if ! test -x $SIM; then
  echo >&2 "Active-HDL simulator not found in $SIM"
#  exit 1
fi

PROG=$ICE_ROOT/../Programmer/3.7_x64/bin/nt64/pgrcmd

# We need any Windows TCL here (Cygwin's TCL will not work)
TCL=$ICE_ROOT/Aldec/Active-HDL/BIN/tclsh85
if ! test -x $TCL; then
  echo >&2 "TCL not found at $TCL"
  exit 1
fi

