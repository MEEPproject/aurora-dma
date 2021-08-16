source [pwd]/tcl/environment.tcl
source [pwd]/tcl/project_options.tcl

set ip_properties [ list \
    vendor "meep-project.eu" \
    library "MEEP" \
    name ${g_design_name} \
    version "$g_ip_version" \
    taxonomy "/MEEP_IP" \
    display_name "MEEP ${g_design_name}" \
    description "We want to package the Aurora DMA design" \
    vendor_display_name "MEEP Project" \
    company_url "https://meep-project.eu/" \
    ]

set family_lifecycle { \
  virtexuplusHBM Production \
}


# Package project and set properties
ipx::package_project
set ip_core [ipx::current_core]
set_property -dict ${ip_properties} ${ip_core}
set_property SUPPORTED_FAMILIES ${family_lifecycle} ${ip_core}

# ipx::add_bus_parameter ID_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]    
# ipx::add_bus_parameter AWUSER_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]
# ipx::add_bus_parameter ARUSER_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]]
# ipx::add_bus_parameter WUSER_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]] 
# ipx::add_bus_parameter BUSER_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]] 
# ipx::add_bus_parameter RUSER_WIDTH [ipx::get_bus_interfaces S_AXI -of_objects [ipx::current_core]] 

## Set the created interface ports
#set_property CONFIG.DATA_WIDTH 256 [get_bd_intf_ports /M_AXI_MM2S]
#set_property CONFIG.FREQ_HZ 402832032 [get_bd_intf_ports /M_AXI_MM2S]
#set_property CONFIG.DATA_WIDTH 256 [get_bd_intf_ports /M_AXI_S2MM]
#set_property CONFIG.FREQ_HZ 402832032 [get_bd_intf_ports /M_AXI_S2MM]



# Associate AXI/AXIS interfaces and reset with clock
#set aclk_intf [ipx::get_bus_interfaces ACLK -of_objects ${ip_core}]
#set aclk_assoc_intf [ipx::add_bus_parameter ASSOCIATED_BUSIF $aclk_intf]
#set_property value M_AXIS:S_AXIS:S_AXI $aclk_assoc_intf
#set aclk_assoc_reset [ipx::add_bus_parameter ASSOCIATED_RESET $aclk_intf]
#set_property value ARESETN $aclk_assoc_reset
#ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces ACLK -of_objects [ipx::current_core]]



#Set clocks
#set user_clk_out_intf [ipx::get_bus_interfaces USER_CLK_OUT -of_objects ${ip_core}]
#set user_clk_out_assoc_intf [ipx::add_bus_parameter ASSOCIATED_BUSIF $user_clk_out_intf]
#set property value M_AXI_MM2S $user_clk_out_assoc_intf
#set property value M_AXI_S2MM $user_clk_out_assoc_intf
#ipx:: add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces USER_CLK_OUT -of_objects [ipx::current_core]]

#set s_axi_lite_dma_aclk_intf [ipx::get_bus_interfaces S_AXI_LITE_DMA_ACLK -of_objects [ipx::current_core]]
#set s_axi_lite_dma_aclk_assoc_intf [ipx::add_bus_parameter ASSOCIATED_BUSIF $s_axi_lite_dma_aclk_intf]
#set property value S_AXI_LITE $s_axi_lite_dma_assoc_intf
#ipx:: add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces S_AXI_LITE_DMA_ACLK -of_objects [ipx::current_core]]

#ipx:: add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces INIT_CLK -of_objects [ipx::current_core]]



# SET SYS_RESET
#set sys_reset_intf [ipx::get_bus_interfaces SYS_RESET -of_objects [ipx::current_core]]
#set sys_reset_polarity [ipx::add_bus_parameter POLARITY $sys_reset_intf]
#set_property value ACTIVE_HIGH ${sys_reset_polarity}






# Set reset polarity
#set aresetn_intf [ipx::get_bus_interfaces ARESETN -of_objects ${ip_core}]
#set aresetn_polarity [ipx::add_bus_parameter POLARITY $aresetn_intf]
#set_property value ACTIVE_LOW ${aresetn_polarity}

#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces RESET -of_objects [ipx::current_core]]
#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces RESET_UI -of_objects [ipx::current_core]]
#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces SYS_RESET_OUT -of_objects [ipx::current_core]]
#ipx:: add_port_map RST [ipx::get_bus_interfaces MM2S_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]
#set_property physical_name MM2S_PRMRY_RESETN_OUT [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces MM2S_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]]
#ipx:: add_port_map RST [ipx::get_bus_interfaces S2MM_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]
#set_property physical_name S2MM_PRMRY_RESETN_OUT [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces S2MM_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]]

#ipx:: infer_bus_interfaces MM2S_PRMRY_RESETN_OUT xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
#ipx:: infer_bus_interfaces S2MM_PRMRY_RESETN_OUT xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces MM2S_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]
#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces S2MM_PRMRY_RESETN_OUT -of_objects [ipx::current_core]]


#ipx::add_segment AXI_DMA_DATA_MM2S [ipx::get_address_spaces M_AXI_MM2S -of_objects [ipx::current_core]]
#ipx::add_segment AXI_DMA_DATA_S2MM [ipx::get_address_spaces M_AXI_S2MM -of_objects [ipx::current_core]]







# Save IP and close project
ipx::check_integrity ${ip_core}
ipx::save_core ${ip_core}

puts "IP succesfully packaged " 
