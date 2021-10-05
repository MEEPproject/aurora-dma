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
################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version $g_vivado_version
set current_vivado_version [version -short]

if { [string first $g_vivado_version $current_vivado_version] == -1 } {
    puts ""
    catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

    return 1
}

################################################################
# START
################################################################
set root_dir [ pwd ]

set g_project_name $g_project_name
set projec_dir $root_dir/project

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
    create_project $g_project_name $projec_dir -force -part $g_fpga_part
}
# Set project properties
# CHANGE DESIGN NAME HERE
variable design_name
set design_name $g_project_name
set ip_dir_list [list \
     $root_dir/ip]
	

set_property  ip_repo_paths  $ip_dir_list [current_project]

if { $g_useBlockDesign eq "Y" } {
create_bd_design -dir $root_dir/bd ${design_name}
update_ip_catalog -rebuild
source ${root_dir}/tcl/gen_bd.tcl
create_root_design ""
validate_bd_design
save_bd_design
}

####################################################
# MAIN FLOW
####################################################
set g_top_name aurora_dma_ip_top
#${g_project_name}_top

set top_module "$root_dir/src/${g_top_name}.vhd"
set src_files [glob ${root_dir}/src/*]
set ip_files [glob -nocomplain ${root_dir}/ip/*/*.xci]
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
#source $root_dir/tcl/gen_runs.tcl
source $root_dir/tcl/project_options.tcl
source $root_dir/tcl/gen_ip.tcl
#source $root_dir/tcl/gen_bitstream.tcl
