#!/bin/sh -e

if test -z "$ICE_ROOT"; then
  ICE_ROOT=/cygdrive/c/lscc/iCEcube2.2016.02
fi

if test -z "$LM_LICENSE_FILE"; then
  export LM_LICENSE_FILE=$ICE_ROOT/license.dat
fi

if ! test -f $LM_LICENSE_FILE; then
  echo >&2 "License file not found at $LM_LICENSE_FILE (need to update LM_LICENSE_FILE env. var.?)"
  exit 1
fi

# Devenv sets same variables for LSE and Synplify
# TODO: add $LSE/Aldec/Active-HDL/BIN to PATH
export FOUNDRY=$(cygpath -w $ICE_ROOT/LSE)
export LC_LICENSE_FILE=$(cygpath -w $LM_LICENSE_FILE)
export PLATFORM=MCD
export SBT_DIR=$(cygpath -w $ICE_ROOT/sbt_backend)
export SYNPLIFY_PATH=$(cygpath -w $ICE_ROOT/synpbase)
export TCL_LIBRARY=$(cygpath -w $ICE_ROOT/sbt_backend/bin/win32/lib/tcl8.4)

LSE_SYNTH=$ICE_ROOT/LSE/bin/nt/synthesis.exe
test -x $LSE_SYNTH

SYN_SYNTH=$ICE_ROOT/sbt_backend/bin/win32/opt/synpwrap/synpwrap.exe
test -x $SYN_SYNTH

# We need any Windows TCL here (Cygwin's TCL will not work)
TCL=$ICE_ROOT/Aldec/Active-HDL/BIN/tclsh85.exe
test -x $TCL

case "$1" in
synplify | syn)
  rc=0
  $SYN_SYNTH -prj syn/primogen_syn.prj || rc=$?
  cat stdout.log
  test $rc=0
  $TCL backend.tcl
  ;;
lattice | lse | '' )
  $LSE_SYNTH -f syn/primogen_lse.prj
  $TCL backend.tcl
  ;;
*)
  echo >&2 "error: unknown toolchain: $1"
  exit 1
  ;;
esac
