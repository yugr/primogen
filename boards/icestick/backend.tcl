set device iCE40LP8K-CM225
set top_module primogen
set proj_dir [pwd]
set output_dir "rev_1"
set edif_file "primogen"
set tool_options ""

set sbt_root $::env(SBT_DIR)
append sbt_tcl $sbt_root "/tcl/sbt_backend_synpl.tcl"
source $sbt_tcl

run_sbt_backend_auto $device $top_module $proj_dir $output_dir $tool_options $edif_file

exit

