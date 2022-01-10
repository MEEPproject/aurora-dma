# Convert AXI stream bus to adapt it to Aurora needs

create_ip -name axis_subset_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_subset_converter_0

set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {32} CONFIG.M_TDATA_NUM_BYTES {32} CONFIG.S_HAS_TREADY {0} CONFIG.M_HAS_TKEEP {1} CONFIG.M_HAS_TLAST {1} CONFIG.DEFAULT_TLAST {8} CONFIG.TDATA_REMAP {tdata[255:0]} CONFIG.TKEEP_REMAP {32'b11111111111111111111111111111111} CONFIG.TLAST_REMAP {tlast[0]}] [get_ips axis_subset_converter_0]

generate_target {instantiation_template} [get_files $g_root_dir/ip/axis_subset_converter_0/axis_subset_converter_0.xci]

# Generate the other direction

create_ip -name axis_subset_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_subset_converter_1

set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {32} CONFIG.M_TDATA_NUM_BYTES {32} CONFIG.S_HAS_TKEEP {1} CONFIG.S_HAS_TLAST {1} CONFIG.TDATA_REMAP {tdata[255:0]}] [get_ips axis_subset_converter_1]

generate_target {instantiation_template} [get_files $g_root_dir/ip/axis_subset_converter_1/axis_subset_converter_1.xci]
