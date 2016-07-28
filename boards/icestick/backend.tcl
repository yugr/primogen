set device iCE40HX1K-TQ144
set top_module top
set proj_dir [pwd]
set output_dir [lindex $argv 0]
set edif_file "top"
set tool_options ":edifparser --physicalconstraint syn/icestick.pcf"

set sbt_root $::env(SBT_DIR)
append sbt_tcl $sbt_root "/tcl/sbt_backend_synpl.tcl"
source $sbt_tcl

run_sbt_backend_auto $device $top_module $proj_dir $output_dir $tool_options $edif_file

exit

