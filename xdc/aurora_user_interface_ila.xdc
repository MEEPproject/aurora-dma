connect_debug_port u_ila_0/probe1 [get_nets [list {axis_ui_tx_tdata[0]} {axis_ui_tx_tdata[1]} {axis_ui_tx_tdata[2]} {axis_ui_tx_tdata[3]} {axis_ui_tx_tdata[4]} {axis_ui_tx_tdata[5]} {axis_ui_tx_tdata[6]} {axis_ui_tx_tdata[7]} {axis_ui_tx_tdata[8]} {axis_ui_tx_tdata[9]} {axis_ui_tx_tdata[10]} {axis_ui_tx_tdata[11]} {axis_ui_tx_tdata[12]} {axis_ui_tx_tdata[13]} {axis_ui_tx_tdata[14]} {axis_ui_tx_tdata[15]} {axis_ui_tx_tdata[16]} {axis_ui_tx_tdata[17]} {axis_ui_tx_tdata[18]} {axis_ui_tx_tdata[19]} {axis_ui_tx_tdata[20]} {axis_ui_tx_tdata[21]} {axis_ui_tx_tdata[22]} {axis_ui_tx_tdata[23]} {axis_ui_tx_tdata[24]} {axis_ui_tx_tdata[25]} {axis_ui_tx_tdata[26]} {axis_ui_tx_tdata[27]} {axis_ui_tx_tdata[28]} {axis_ui_tx_tdata[29]} {axis_ui_tx_tdata[30]} {axis_ui_tx_tdata[31]} {axis_ui_tx_tdata[32]} {axis_ui_tx_tdata[33]} {axis_ui_tx_tdata[34]} {axis_ui_tx_tdata[35]} {axis_ui_tx_tdata[36]} {axis_ui_tx_tdata[37]} {axis_ui_tx_tdata[38]} {axis_ui_tx_tdata[39]} {axis_ui_tx_tdata[40]} {axis_ui_tx_tdata[41]} {axis_ui_tx_tdata[42]} {axis_ui_tx_tdata[43]} {axis_ui_tx_tdata[44]} {axis_ui_tx_tdata[45]} {axis_ui_tx_tdata[46]} {axis_ui_tx_tdata[47]} {axis_ui_tx_tdata[48]} {axis_ui_tx_tdata[49]} {axis_ui_tx_tdata[50]} {axis_ui_tx_tdata[51]} {axis_ui_tx_tdata[52]} {axis_ui_tx_tdata[53]} {axis_ui_tx_tdata[54]} {axis_ui_tx_tdata[55]} {axis_ui_tx_tdata[56]} {axis_ui_tx_tdata[57]} {axis_ui_tx_tdata[58]} {axis_ui_tx_tdata[59]} {axis_ui_tx_tdata[60]} {axis_ui_tx_tdata[61]} {axis_ui_tx_tdata[62]} {axis_ui_tx_tdata[63]}]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list aurora_0/inst/clock_module_i/ultrascale_tx_userclk_1/init_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {data_err_count[0]} {data_err_count[1]} {data_err_count[2]} {data_err_count[3]} {data_err_count[4]} {data_err_count[5]} {data_err_count[6]} {data_err_count[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 64 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {axis_ui_rx_tdata[0]} {axis_ui_rx_tdata[1]} {axis_ui_rx_tdata[2]} {axis_ui_rx_tdata[3]} {axis_ui_rx_tdata[4]} {axis_ui_rx_tdata[5]} {axis_ui_rx_tdata[6]} {axis_ui_rx_tdata[7]} {axis_ui_rx_tdata[8]} {axis_ui_rx_tdata[9]} {axis_ui_rx_tdata[10]} {axis_ui_rx_tdata[11]} {axis_ui_rx_tdata[12]} {axis_ui_rx_tdata[13]} {axis_ui_rx_tdata[14]} {axis_ui_rx_tdata[15]} {axis_ui_rx_tdata[16]} {axis_ui_rx_tdata[17]} {axis_ui_rx_tdata[18]} {axis_ui_rx_tdata[19]} {axis_ui_rx_tdata[20]} {axis_ui_rx_tdata[21]} {axis_ui_rx_tdata[22]} {axis_ui_rx_tdata[23]} {axis_ui_rx_tdata[24]} {axis_ui_rx_tdata[25]} {axis_ui_rx_tdata[26]} {axis_ui_rx_tdata[27]} {axis_ui_rx_tdata[28]} {axis_ui_rx_tdata[29]} {axis_ui_rx_tdata[30]} {axis_ui_rx_tdata[31]} {axis_ui_rx_tdata[32]} {axis_ui_rx_tdata[33]} {axis_ui_rx_tdata[34]} {axis_ui_rx_tdata[35]} {axis_ui_rx_tdata[36]} {axis_ui_rx_tdata[37]} {axis_ui_rx_tdata[38]} {axis_ui_rx_tdata[39]} {axis_ui_rx_tdata[40]} {axis_ui_rx_tdata[41]} {axis_ui_rx_tdata[42]} {axis_ui_rx_tdata[43]} {axis_ui_rx_tdata[44]} {axis_ui_rx_tdata[45]} {axis_ui_rx_tdata[46]} {axis_ui_rx_tdata[47]} {axis_ui_rx_tdata[48]} {axis_ui_rx_tdata[49]} {axis_ui_rx_tdata[50]} {axis_ui_rx_tdata[51]} {axis_ui_rx_tdata[52]} {axis_ui_rx_tdata[53]} {axis_ui_rx_tdata[54]} {axis_ui_rx_tdata[55]} {axis_ui_rx_tdata[56]} {axis_ui_rx_tdata[57]} {axis_ui_rx_tdata[58]} {axis_ui_rx_tdata[59]} {axis_ui_rx_tdata[60]} {axis_ui_rx_tdata[61]} {axis_ui_rx_tdata[62]} {axis_ui_rx_tdata[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 64 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {axis_ui_tx_tdata[0]} {axis_ui_tx_tdata[1]} {axis_ui_tx_tdata[2]} {axis_ui_tx_tdata[3]} {axis_ui_tx_tdata[4]} {axis_ui_tx_tdata[5]} {axis_ui_tx_tdata[6]} {axis_ui_tx_tdata[7]} {axis_ui_tx_tdata[8]} {axis_ui_tx_tdata[9]} {axis_ui_tx_tdata[10]} {axis_ui_tx_tdata[11]} {axis_ui_tx_tdata[12]} {axis_ui_tx_tdata[13]} {axis_ui_tx_tdata[14]} {axis_ui_tx_tdata[15]} {axis_ui_tx_tdata[16]} {axis_ui_tx_tdata[17]} {axis_ui_tx_tdata[18]} {axis_ui_tx_tdata[19]} {axis_ui_tx_tdata[20]} {axis_ui_tx_tdata[21]} {axis_ui_tx_tdata[22]} {axis_ui_tx_tdata[23]} {axis_ui_tx_tdata[24]} {axis_ui_tx_tdata[25]} {axis_ui_tx_tdata[26]} {axis_ui_tx_tdata[27]} {axis_ui_tx_tdata[28]} {axis_ui_tx_tdata[29]} {axis_ui_tx_tdata[30]} {axis_ui_tx_tdata[31]} {axis_ui_tx_tdata[32]} {axis_ui_tx_tdata[33]} {axis_ui_tx_tdata[34]} {axis_ui_tx_tdata[35]} {axis_ui_tx_tdata[36]} {axis_ui_tx_tdata[37]} {axis_ui_tx_tdata[38]} {axis_ui_tx_tdata[39]} {axis_ui_tx_tdata[40]} {axis_ui_tx_tdata[41]} {axis_ui_tx_tdata[42]} {axis_ui_tx_tdata[43]} {axis_ui_tx_tdata[44]} {axis_ui_tx_tdata[45]} {axis_ui_tx_tdata[46]} {axis_ui_tx_tdata[47]} {axis_ui_tx_tdata[48]} {axis_ui_tx_tdata[49]} {axis_ui_tx_tdata[50]} {axis_ui_tx_tdata[51]} {axis_ui_tx_tdata[52]} {axis_ui_tx_tdata[53]} {axis_ui_tx_tdata[54]} {axis_ui_tx_tdata[55]} {axis_ui_tx_tdata[56]} {axis_ui_tx_tdata[57]} {axis_ui_tx_tdata[58]} {axis_ui_tx_tdata[59]} {axis_ui_tx_tdata[60]} {axis_ui_tx_tdata[61]} {axis_ui_tx_tdata[62]} {axis_ui_tx_tdata[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list axis_ui_rx_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list axis_ui_tx_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list axis_ui_tx_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list channel_up_out]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list lane_up_out]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets init_clk_in]
