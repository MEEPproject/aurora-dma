namespace eval _tcl {
proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

puts "The environment tcl will be sourced from ${script_folder}"
source $script_folder/environment.tcl

# Redefine the FPGA part in case the script is called with arguments
# It defaults to u280
if { $::argc > 0 } {

        set g_board_part [lindex $argv 0]
        set g_fpga_part "xc${g_board_part}-fsvh2892-2L-e"

}

################################################################
# START
################################################################

set g_project_name $g_project_name
set projec_dir $g_root_dir/project

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
    create_project $g_project_name $projec_dir -force -part $g_fpga_part
}
# Set project properties
# CHANGE DESIGN NAME HERE
variable design_name
set design_name $g_project_name
set ip_dir_list [list \
     $g_root_dir/ip]
	

set_property  ip_repo_paths  $ip_dir_list [current_project]

if { $g_useBlockDesign eq "Y" } {
create_bd_design -dir $root_dir/bd ${design_name}
update_ip_catalog -rebuild
source ${g_root_dir}/tcl/gen_bd.tcl
create_root_design ""
validate_bd_design
save_bd_design
}

####################################################
# MAIN FLOW
####################################################
set g_top_name aurora_dma_ip_top
#${g_project_name}_top

set top_module "$g_root_dir/src/${g_top_name}.vhd"
set src_files [glob ${g_root_dir}/src/*]
set ip_files [glob -nocomplain ${g_root_dir}/ip/*/*.xci]
add_files ${src_files}
add_files -quiet ${ip_files}

upgrade_ip [get_ips {axi_dma_0}]
upgrade_ip -vlnv xilinx.com:ip:aurora_64b66b:12.0 [get_ips {aurora_64b66b_0}] -log ip_upgrade.log
upgrade_ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 [get_ips {axis_subset_converter_0}] -log ip_upgrade.log
upgrade_ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 [get_ips {axis_subset_converter_1}] -log ip_upgrade.log


# Add Constraint files to project
#add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_project_name}_pinout.xdc"
#add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_project_name}_timing.xdc"
#add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_project_name}_ila.xdc"
#add_files -fileset [get_filesets constrs_1] "$root_dir/xdc/${g_project_name}_alveo280.xdc"
set_property target_language VHDL [current_project]
puts "Project generation ended successfully"
#source $g_root_dir/tcl/gen_runs.tcl
source $g_root_dir/tcl/project_options.tcl
source $g_root_dir/tcl/gen_ip.tcl
#source $g_root_dir/tcl/gen_bitstream.tcl
