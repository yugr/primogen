set sbt_root $::env(SBT_DIR)
append sbt_tcl $sbt_root "/tcl/sbt_backend_synpl.tcl"
source $sbt_tcl

set device iCE40HX1K-TQ144
set top_module [lindex $argv 0]
set proj_dir [pwd]
set tool_options ":edifparser --physicalconstraint syn/icestick.pcf"
set edif_file $top_module

run_sbt_backend_auto $device $top_module $proj_dir "bin" $tool_options $edif_file

