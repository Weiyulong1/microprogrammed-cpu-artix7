set root [file dirname [file normalize [info script]]]
create_project microprogrammed_cpu [file join $root build] -part xc7a75tfgg484-2 -force
add_files -fileset sources_1 [glob [file join $root rtl *.v]]
add_files -fileset constrs_1 [file join $root constraints CPU.xdc]
add_files -fileset sim_1 [file join $root sim cpu_tb.v]
set_property top cpu_top [get_filesets sources_1]
set_property top cpu_tb [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
