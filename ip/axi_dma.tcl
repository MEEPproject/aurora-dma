# Create and configure the Xilinx AXI DMA IP to work with Aurora

create_ip -name axi_dma -vendor xilinx.com -library ip -version 7.1 -module_name axi_dma_0

set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_length_width {16} CONFIG.c_prmry_is_aclk_async {1} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_m_axi_mm2s_data_width {256} CONFIG.c_m_axis_mm2s_tdata_width {256} CONFIG.c_mm2s_burst_size {4} CONFIG.c_m_axi_s2mm_data_width {256} CONFIG.c_s_axis_s2mm_tdata_width {256} CONFIG.c_s2mm_burst_size {4}] [get_ips axi_dma_0]

# Generate the xci file
generate_target {instantiation_template} [get_files $g_root_dir/axi_dma/axi_dma_0.xci]

