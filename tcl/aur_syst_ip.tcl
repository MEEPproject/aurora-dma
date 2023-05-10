# Copyright 2022 Barcelona Supercomputing Center-Centro Nacional de Supercomputación

# Licensed under the Solderpad Hardware License v 2.1 (the "License");
# you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
# You may obtain a copy of the License at
# 
#     http://www.solderpad.org/licenses/SHL-2.1
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Alexander Kropotov, BSC-CNS
# Date: 22.02.2022
# Description: 



# Script to generate IP core of isolated Ethernet subsystem
#
#

#source $root_dir/tcl/environment.tcl
source $g_root_dir/tcl/project_options.tcl


set ip_properties [ list \
    vendor "meep-project.eu" \
    library "MEEP" \
    name "MEEP_${g_design_name}" \
    version "$g_ip_version" \
    taxonomy "/MEEP_IP" \
    display_name "${g_ip_description}" \
    description  "${g_ip_description}" \
    vendor_display_name "MEEP Project" \
    vendor_display_name "bsc.es" \
    company_url "https://meep-project.eu/" \
    ]

set family_lifecycle { \
  virtexuplusHBM Production \
}


ipx::package_project -root_dir $g_root_dir/ip -module $g_design_name -import_files

set ip_core [ipx::current_core]
set_property -dict ${ip_properties} ${ip_core}
set_property SUPPORTED_FAMILIES ${family_lifecycle} ${ip_core}

ipx::add_user_parameter Board                                                    $ip_core
set board_param [ipx::get_user_parameters Board -of_objects                      $ip_core]
set_property value_resolve_type user                             $board_param
ipgui::add_param -name {Board} -component                                        $ip_core
set_property widget {comboBox} [ipgui::get_guiparamspec -name "Board" -component $ip_core]
set_property value_validation_type list                          $board_param
set_property value_validation_list "$g_board_part $g_board_part" $board_param
set_property value                                $g_board_part  $board_param

ipx::add_user_parameter QSFP_Port                                                    $ip_core
set port_param [ipx::get_user_parameters QSFP_Port -of_objects                       $ip_core]
set_property value_resolve_type user                         $port_param
ipgui::add_param -name {QSFP_Port} -component                                        $ip_core
set_property widget {comboBox} [ipgui::get_guiparamspec -name "QSFP_Port" -component $ip_core]
set_property value_validation_type list                      $port_param
set_property value_validation_list "$g_eth_port $g_eth_port" $port_param
set_property value                              $g_eth_port  $port_param

ipx::add_user_parameter DMA_memory                                                   $ip_core
set mem_param [ipx::get_user_parameters DMA_memory -of_objects                       $ip_core]
set_property value_resolve_type user                   $mem_param
ipgui::add_param -name {DMA_memory} -component                                        $ip_core
set_property widget {comboBox} [ipgui::get_guiparamspec -name "DMA_memory" -component $ip_core]
set_property value_validation_type list                $mem_param
if { ${g_dma_mem} eq "sram" } {
  set dma_mem "internal($g_dma_mem)"
}
if { ${g_dma_mem} eq "hbm" } {
  set dma_mem "external($g_dma_mem)"
}
set_property value_validation_list "$dma_mem $dma_mem" $mem_param
set_property value                           $dma_mem  $mem_param

# explicitely removing AXI signals auto-aded in BD Verilog in spite they are absent in BD itself
ipx::remove_port s_axi_awprot $ip_core
ipx::remove_port s_axi_arprot $ip_core

## Relative path to IP root directory
ipx::create_xgui_files ${ip_core} -logo_file "$g_root_dir/misc/BSC-Logo.png"
set_property type LOGO [ipx::get_files "$g_root_dir/misc/BSC-Logo.png" -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]
ipx::update_checksums ${ip_core}

# Save IP and close project
ipx::check_integrity ${ip_core}
ipx::save_core ${ip_core}

ipx::archive_core $g_root_dir/ip/${g_design_name}.zip
ipx::unload_core $g_root_dir/ip/component.xml

update_ip_catalog -rebuild

puts "IP succesfully packaged "
