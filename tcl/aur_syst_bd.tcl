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
# Date: 11.05.2023
# Description: 


# Proc to create BD
proc cr_bd_aurora_dma { parentCell } {

  global g_root_dir
  global g_design_name
  global g_board_part
  global g_eth_port
  global g_dma_mem
  global g_saxi_freq
  global g_saxi_prot
  # CHANGE DESIGN NAME HERE
  set design_name $g_design_name

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir $g_root_dir/bd

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:xlconcat:2.1\
  xilinx.com:ip:axi_register_slice:2.1\
  xilinx.com:ip:axi_timer:2.0\
  xilinx.com:ip:xlconstant:1.1\
  xilinx.com:ip:axis_data_fifo:2.0\
  xilinx.com:ip:aurora_64b66b:12.0\
  xilinx.com:ip:axi_dma:7.1\
  xilinx.com:ip:blk_mem_gen:8.4\
  xilinx.com:ip:util_vector_logic:2.0\
  xilinx.com:ip:axi_gpio:2.0\
  xilinx.com:ip:xlslice:1.0\
  xilinx.com:ip:axis_switch:1.1\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:smartconnect:1.0\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
if { ${g_dma_mem} eq "hbm" } {
  set m_axi_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_rx ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {40} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {0} \
   CONFIG.NUM_READ_OUTSTANDING {256} \
   CONFIG.NUM_WRITE_OUTSTANDING {256} \
   CONFIG.PROTOCOL {AXI3} \
   CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
   ] $m_axi_rx

  set m_axi_sg [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_sg ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {40} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {256} \
   CONFIG.NUM_WRITE_OUTSTANDING {256} \
   CONFIG.PROTOCOL {AXI3} \
   ] $m_axi_sg

  set m_axi_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_tx ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {40} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_BRESP {0} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.NUM_READ_OUTSTANDING {256} \
   CONFIG.NUM_WRITE_OUTSTANDING {256} \
   CONFIG.PROTOCOL {AXI3} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   ] $m_axi_tx
}

  set qsfp_rx_4x [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 qsfp_rx_4x ]
  set qsfp_tx_4x [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 qsfp_tx_4x ]

  set AXIProt  [string replace $g_saxi_prot   [string first "-" $g_saxi_prot] end]
  set AXIWidth [string replace $g_saxi_prot 0 [string first "-" $g_saxi_prot]    ]
  set s_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {22} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH $AXIWidth \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {256} \
   CONFIG.NUM_READ_THREADS {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {256} \
   CONFIG.NUM_WRITE_THREADS {16} \
   CONFIG.PROTOCOL $AXIProt \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $s_axi


  # Create ports
  set intc [ create_bd_port -dir O -from 1 -to 0 intc ]

if { ${g_dma_mem} eq "hbm" } {
  set rx_clk [ create_bd_port -dir O -type clk rx_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m_axi_rx} \
   CONFIG.ASSOCIATED_RESET {rx_rstn} \
 ] $rx_clk
  set rx_rstn [ create_bd_port -dir O -from 0 -to 0 -type rst rx_rstn ]
  set tx_clk [ create_bd_port -dir O -type clk tx_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m_axi_tx} \
   CONFIG.ASSOCIATED_RESET {tx_rstn} \
 ] $tx_clk
  set tx_rstn [ create_bd_port -dir O -from 0 -to 0 -type rst tx_rstn ]
}

  set s_axi_clk [ create_bd_port -dir I -type clk -freq_hz $g_saxi_freq s_axi_clk ]
  set s_axi_resetn [ create_bd_port -dir I -type rst s_axi_resetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $s_axi_resetn

  # Create instance: GT_STATUS, and set properties
  set GT_STATUS [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 GT_STATUS ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {13} \
 ] $GT_STATUS


if { ${g_dma_mem} eq "hbm" } {
  # Create instance: axi_reg_slice_rx, and set properties
  set axi_reg_slice_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_reg_slice_rx ]
  set_property -dict [ list \
   CONFIG.REG_AR {15} \
   CONFIG.REG_AW {15} \
   CONFIG.REG_B {15} \
   CONFIG.REG_R {15} \
   CONFIG.REG_W {15} \
   CONFIG.USE_AUTOPIPELINING {1} \
 ] $axi_reg_slice_rx

  # Create instance: axi_reg_slice_tx, and set properties
  set axi_reg_slice_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_reg_slice_tx ]
  set_property -dict [ list \
   CONFIG.REG_AR {15} \
   CONFIG.REG_AW {15} \
   CONFIG.REG_B {15} \
   CONFIG.REG_R {15} \
   CONFIG.REG_W {15} \
   CONFIG.USE_AUTOPIPELINING {1} \
 ] $axi_reg_slice_tx
}

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]
  set_property -dict [ list \
   CONFIG.enable_timer2 {1} \
 ] $axi_timer_0

  # Create instance: concat_intc, and set properties
  set concat_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_intc ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {2} \
 ] $concat_intc

  # Create instance: const_gnd, and set properties
  set const_gnd [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_gnd ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $const_gnd

  # Create instance: const_gndx14, and set properties
  set const_gndx14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_gndx14 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {14} \
 ] $const_gndx14

if { ${g_dma_mem} eq "hbm" } {
  # Create instance: dma_connect_rx, and set properties
  set dma_connect_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_rx ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_rx

  # Create instance: dma_connect_sg, and set properties
  set dma_connect_sg [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_sg ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_sg

  # Create instance: dma_connect_tx, and set properties
  set dma_connect_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 dma_connect_tx ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $dma_connect_tx
}

  # Create instance: aurora_64b66b_0, and set properties
  if { ${g_board_part} eq "u280" } {
    set g_eth100gb_freq "156.25"
    if { ${g_eth_port} eq "qsfp0" } {
      set g_quad_loc      "Quad_X0Y10"
      set g_lane1_loc     "X0Y40"
    }
    if { ${g_eth_port} eq "qsfp1" } {
      set g_quad_loc      "Quad_X0Y11"
      set g_lane1_loc     "X0Y44"
    }
  }
  if { ${g_board_part} eq "u55c" } {
    set g_eth100gb_freq "161.1328125"
    if { ${g_eth_port} eq "qsfp0" } {
      set g_quad_loc      "Quad_X0Y6"
      set g_lane1_loc     "X0Y24"
    }
    if { ${g_eth_port} eq "qsfp1" } {
      set g_quad_loc      "Quad_X0Y7"
      set g_lane1_loc     "X0Y28"
    }
  }
  set aurora_64b66b_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:12.0 aurora_64b66b_0 ]
  set_property -dict [ list \
   CONFIG.C_AURORA_LANES {4} \
   CONFIG.C_REFCLK_FREQUENCY $g_eth100gb_freq \
   CONFIG.C_START_LANE $g_lane1_loc \
   CONFIG.C_START_QUAD $g_quad_loc \
   CONFIG.C_UCOLUMN_USED {left} \
   CONFIG.SupportLevel {1} \
   CONFIG.drp_mode {Disabled} \
 ] $aurora_64b66b_0
  set_property USER_COMMENTS.comment_1 "Debug AXI inteface is disabled for Aurora, otherwise channel_up and lane_up signals never become activated." [get_bd_cells aurora_64b66b_0]
  set_property USER_COMMENTS.comment_2 "pma_init resets both serial GT and Aurora: https://docs.xilinx.com/r/en-US/pg074-aurora-64b66b/Reset"        [get_bd_pins /aurora_64b66b_0/pma_init]
  set_property USER_COMMENTS.comment_3 "https://www.xilinx.com/support/documentation/user_guides/ug578-ultrascale-gty-transceivers.pdf#page=88"      [get_bd_pins /aurora_64b66b_0/loopback]

  set g_refport_freq [format {%0.0f} [expr {$g_eth100gb_freq*1000000+0.5}] ]
  puts "PORT FREQUENCY: $g_refport_freq"
  set qsfp_refck [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 qsfp_refck ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ $g_refport_freq \
   ] $qsfp_refck

  # Create instance: eth_dma, and set properties
  set eth_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 eth_dma ]
  set_property -dict [ list \
   CONFIG.c_addr_width {40} \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_include_sg {1} \
   CONFIG.c_m_axi_mm2s_data_width {256} \
   CONFIG.c_m_axis_mm2s_tdata_width {256} \
   CONFIG.c_mm2s_burst_size {128} \
   CONFIG.c_s2mm_burst_size {128} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {22} \
 ] $eth_dma

if { ${g_dma_mem} eq "sram" } {
  # Create instance: eth_rx_mem, and set properties
  set eth_rx_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 eth_rx_mem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {false} \
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {WRITE_FIRST} \
   CONFIG.Operating_Mode_B {WRITE_FIRST} \
   CONFIG.PRIM_type_to_Implement {BRAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $eth_rx_mem

  # Create instance: eth_sg_mem, and set properties
  set eth_sg_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 eth_sg_mem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {NO_CHANGE} \
   CONFIG.PRIM_type_to_Implement {URAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $eth_sg_mem

  # Create instance: eth_tx_mem, and set properties
  set eth_tx_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 eth_tx_mem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {false} \
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {WRITE_FIRST} \
   CONFIG.Operating_Mode_B {WRITE_FIRST} \
   CONFIG.PRIM_type_to_Implement {BRAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $eth_tx_mem
}

  # Create instance: aur_sysrst_inv, and set properties
  set aur_sysrst_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 aur_sysrst_inv ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $aur_sysrst_inv

  # Create instance: ext_rst_inv, and set properties
  set ext_rst_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 ext_rst_inv ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $ext_rst_inv

  # Create instance: gt_ctl, and set properties
  set gt_ctl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 gt_ctl ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {0} \
   CONFIG.C_ALL_OUTPUTS {0} \
   CONFIG.C_IS_DUAL {0} \
 ] $gt_ctl


  # Create instance: rx_axis_switch, and set properties
  set rx_axis_switch [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 rx_axis_switch ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {2} \
   CONFIG.ROUTING_MODE {1} \
 ] $rx_axis_switch

  # Create instance: gt_ctl_3, and set properties
  set gt_ctl_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gt_ctl_3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {3} \
   CONFIG.DIN_TO {3} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gt_ctl_3

  # Create instance: gt_ctl_4, and set properties
  set gt_ctl_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gt_ctl_4 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {4} \
   CONFIG.DIN_TO {4} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gt_ctl_4

  # Create instance: gt_ctl_5, and set properties
  set gt_ctl_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gt_ctl_5 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {5} \
   CONFIG.DIN_TO {5} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gt_ctl_5

  # Create instance: gt_ctl_6, and set properties
  set gt_ctl_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gt_ctl_6 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {6} \
   CONFIG.DIN_TO {6} \
   CONFIG.DOUT_WIDTH {1} \
 ] $gt_ctl_6

  # Create instance: gt_rst_comb, and set properties
  set gt_rst_comb [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 gt_rst_comb ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $gt_rst_comb

if { ${g_dma_mem} eq "sram" } {
  # Create instance: rx_mem_cpu, and set properties
  set rx_mem_cpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 rx_mem_cpu ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $rx_mem_cpu

  # Create instance: rx_mem_dma, and set properties
  set rx_mem_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 rx_mem_dma ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $rx_mem_dma

  # Create instance: sg_mem_cpu, and set properties
  set sg_mem_cpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 sg_mem_cpu ]
  set_property -dict [ list \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $sg_mem_cpu

  # Create instance: sg_mem_dma, and set properties
  set sg_mem_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 sg_mem_dma ]
  set_property -dict [ list \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $sg_mem_dma

  # Create instance: tx_mem_cpu, and set properties
  set tx_mem_cpu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 tx_mem_cpu ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $tx_mem_cpu

  # Create instance: tx_mem_dma, and set properties
  set tx_mem_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 tx_mem_dma ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.ECC_TYPE {0} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $tx_mem_dma
}

if { ${g_dma_mem} eq "hbm" } {
  # Create instance: rstext_0, and set properties
  set rstext_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 rstext_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $rstext_0

  # Create instance: rstext_1, and set properties
  set rstext_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 rstext_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $rstext_1

  # Create instance: rstint_0, and set properties
  set rstint_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 rstint_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $rstint_0

  # Create instance: rstint_1, and set properties
  set rstint_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 rstint_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $rstint_1


  # Create instance: rx_fifo, and set properties
  set rx_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 rx_fifo ]
  set_property USER_COMMENTS.comment_6 "FIFO depth is set to 256 to fit max CMAC packet 150 x 64bytes = 9600 bytes.
But functionality is fine for at least depth 16." [get_bd_cells /rx_fifo]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {256} \
   CONFIG.IS_ACLK_ASYNC {0} \
 ] $rx_fifo

  # Create instance: txrx_rst_gen, and set properties
  set txrx_rst_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 txrx_rst_gen ]
  set_property -dict [ list \
   CONFIG.C_NUM_INTERCONNECT_ARESETN {2} \
   CONFIG.C_NUM_PERP_ARESETN {2} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $txrx_rst_gen
}

  # Create instance: periph_connect, and set properties
  set periph_connect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 periph_connect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {8} \
   CONFIG.NUM_SI {1} \
 ] $periph_connect
if { ${g_dma_mem} eq "hbm" } {
  set_property -dict [list CONFIG.NUM_MI {5}] [get_bd_cells periph_connect]
}

  # Create instance: tx_axis_switch, and set properties
  set tx_axis_switch [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 tx_axis_switch ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {2} \
   CONFIG.ROUTING_MODE {1} \
 ] $tx_axis_switch

  # Create interface connections
  connect_bd_intf_net -intf_net aurora_64b66b_0_GT_DIFF_REFCLK1 [get_bd_intf_ports qsfp_refck] [get_bd_intf_pins aurora_64b66b_0/GT_DIFF_REFCLK1]
  connect_bd_intf_net -intf_net aurora_64b66b_0_GT_SERIAL_RX [get_bd_intf_ports qsfp_rx_4x] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net aurora_64b66b_0_GT_SERIAL_TX [get_bd_intf_ports qsfp_tx_4x] [get_bd_intf_pins aurora_64b66b_0/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net periph_connect_M00_AXI [get_bd_intf_pins eth_dma/S_AXI_LITE] [get_bd_intf_pins periph_connect/M00_AXI]
  connect_bd_intf_net -intf_net periph_connect_M01_AXI [get_bd_intf_pins periph_connect/M01_AXI] [get_bd_intf_pins tx_axis_switch/S_AXI_CTRL]
  connect_bd_intf_net -intf_net periph_connect_M02_AXI [get_bd_intf_pins periph_connect/M02_AXI] [get_bd_intf_pins rx_axis_switch/S_AXI_CTRL]
  connect_bd_intf_net -intf_net periph_connect_M03_AXI [get_bd_intf_pins gt_ctl/S_AXI] [get_bd_intf_pins periph_connect/M03_AXI]
  connect_bd_intf_net -intf_net periph_connect_M04_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins periph_connect/M04_AXI]
  connect_bd_intf_net -intf_net periph_connect_S00_AXI [get_bd_intf_ports s_axi] [get_bd_intf_pins periph_connect/S00_AXI]
  connect_bd_intf_net -intf_net tx_axis_switch_M01_AXIS [get_bd_intf_pins aurora_64b66b_0/USER_DATA_S_AXIS_TX] [get_bd_intf_pins tx_axis_switch/M01_AXIS]
  connect_bd_intf_net -intf_net rx_axis_switch_M00_AXIS [get_bd_intf_pins rx_axis_switch/M00_AXIS] [get_bd_intf_pins tx_axis_switch/S00_AXIS]
  connect_bd_intf_net -intf_net rx_axis_switch_M01_AXIS [get_bd_intf_pins eth_dma/S_AXIS_S2MM] [get_bd_intf_pins rx_axis_switch/M01_AXIS]
  connect_bd_intf_net -intf_net tx_axis_switch_S01_AXIS [get_bd_intf_pins eth_dma/M_AXIS_MM2S] [get_bd_intf_pins tx_axis_switch/S01_AXIS]
  connect_bd_intf_net -intf_net tx_axis_switch_M00_AXIS [get_bd_intf_pins rx_axis_switch/S00_AXIS] [get_bd_intf_pins tx_axis_switch/M00_AXIS]
if { ${g_dma_mem} eq "sram" } {
  connect_bd_intf_net -intf_net tx_mem_cpu_BRAM_PORTA [get_bd_intf_pins eth_tx_mem/BRAM_PORTA] [get_bd_intf_pins tx_mem_cpu/BRAM_PORTA]
  connect_bd_intf_net -intf_net rx_axis_switch_S01_AXIS [get_bd_intf_pins aurora_64b66b_0/USER_DATA_M_AXIS_RX] [get_bd_intf_pins rx_axis_switch/S01_AXIS]
  connect_bd_intf_net -intf_net tx_mem_dma_S_AXI [get_bd_intf_pins eth_dma/M_AXI_MM2S] [get_bd_intf_pins tx_mem_dma/S_AXI]
  connect_bd_intf_net -intf_net rx_mem_dma_S_AXI [get_bd_intf_pins eth_dma/M_AXI_S2MM] [get_bd_intf_pins rx_mem_dma/S_AXI]
  connect_bd_intf_net -intf_net sg_mem_dma_S_AXI [get_bd_intf_pins eth_dma/M_AXI_SG] [get_bd_intf_pins sg_mem_dma/S_AXI]
  connect_bd_intf_net -intf_net rx_mem_cpu_BRAM_PORTA [get_bd_intf_pins eth_rx_mem/BRAM_PORTA] [get_bd_intf_pins rx_mem_cpu/BRAM_PORTA]
  connect_bd_intf_net -intf_net rx_mem_dma_BRAM_PORTA [get_bd_intf_pins eth_rx_mem/BRAM_PORTB] [get_bd_intf_pins rx_mem_dma/BRAM_PORTA]
  connect_bd_intf_net -intf_net sg_mem_cpu_BRAM_PORTA [get_bd_intf_pins eth_sg_mem/BRAM_PORTA] [get_bd_intf_pins sg_mem_cpu/BRAM_PORTA]
  connect_bd_intf_net -intf_net sg_mem_dma_BRAM_PORTA [get_bd_intf_pins eth_sg_mem/BRAM_PORTB] [get_bd_intf_pins sg_mem_dma/BRAM_PORTA]
  connect_bd_intf_net -intf_net periph_connect_M05_AXI [get_bd_intf_pins periph_connect/M05_AXI] [get_bd_intf_pins tx_mem_cpu/S_AXI]
  connect_bd_intf_net -intf_net periph_connect_M06_AXI [get_bd_intf_pins periph_connect/M06_AXI] [get_bd_intf_pins rx_mem_cpu/S_AXI]
  connect_bd_intf_net -intf_net periph_connect_M07_AXI [get_bd_intf_pins periph_connect/M07_AXI] [get_bd_intf_pins sg_mem_cpu/S_AXI]
  connect_bd_intf_net -intf_net tx_mem_dma_BRAM_PORTA [get_bd_intf_pins eth_tx_mem/BRAM_PORTB] [get_bd_intf_pins tx_mem_dma/BRAM_PORTA]
}
if { ${g_dma_mem} eq "hbm" } {
  connect_bd_intf_net -intf_net aurora_64b66b_0_USER_DATA_M_AXIS_RX [get_bd_intf_pins aurora_64b66b_0/USER_DATA_M_AXIS_RX] [get_bd_intf_pins rx_fifo/S_AXIS]
  connect_bd_intf_net -intf_net axi_reg_slice_rx_M_AXI [get_bd_intf_ports m_axi_rx] [get_bd_intf_pins axi_reg_slice_rx/M_AXI]
  connect_bd_intf_net -intf_net axi_reg_slice_tx_M_AXI [get_bd_intf_ports m_axi_tx] [get_bd_intf_pins axi_reg_slice_tx/M_AXI]
  connect_bd_intf_net -intf_net dma_connect_rx_M00_AXI [get_bd_intf_pins axi_reg_slice_rx/S_AXI] [get_bd_intf_pins dma_connect_rx/M00_AXI]
  connect_bd_intf_net -intf_net dma_connect_tx_M00_AXI [get_bd_intf_pins axi_reg_slice_tx/S_AXI] [get_bd_intf_pins dma_connect_tx/M00_AXI]
  connect_bd_intf_net -intf_net dma_connect_tx_S00_AXI [get_bd_intf_pins dma_connect_tx/S00_AXI] [get_bd_intf_pins eth_dma/M_AXI_MM2S]
  connect_bd_intf_net -intf_net dma_connect_rx_S00_AXI [get_bd_intf_pins dma_connect_rx/S00_AXI] [get_bd_intf_pins eth_dma/M_AXI_S2MM]
  connect_bd_intf_net -intf_net dma_connect_sg_S00_AXI [get_bd_intf_pins dma_connect_sg/S00_AXI] [get_bd_intf_pins eth_dma/M_AXI_SG]
  connect_bd_intf_net -intf_net rx_axis_switch_S01_AXIS [get_bd_intf_pins rx_axis_switch/S01_AXIS] [get_bd_intf_pins rx_fifo/M_AXIS]
  connect_bd_intf_net -intf_net dma_connect_sg_M00_AXI [get_bd_intf_ports m_axi_sg] [get_bd_intf_pins dma_connect_sg/M00_AXI]
}

  # Create port connections
  connect_bd_net -net GT_STATUS_dout [get_bd_pins GT_STATUS/dout] [get_bd_pins gt_ctl/gpio_io_i]
  connect_bd_net -net aurora_64b66b_0_channel_up [get_bd_pins GT_STATUS/In6] [get_bd_pins aurora_64b66b_0/channel_up]
  connect_bd_net -net aurora_64b66b_0_gt_qplllock_quad1_out [get_bd_pins GT_STATUS/In3] [get_bd_pins aurora_64b66b_0/gt_qplllock_quad1_out]
  connect_bd_net -net aurora_64b66b_0_gt_qpllrefclklost_quad1_out [get_bd_pins GT_STATUS/In4] [get_bd_pins aurora_64b66b_0/gt_qpllrefclklost_quad1_out]
  connect_bd_net -net aurora_64b66b_0_hard_err [get_bd_pins GT_STATUS/In10] [get_bd_pins aurora_64b66b_0/hard_err]
  connect_bd_net -net aurora_64b66b_0_lane_up [get_bd_pins GT_STATUS/In5] [get_bd_pins aurora_64b66b_0/lane_up]
  connect_bd_net -net aurora_64b66b_0_link_reset_out [get_bd_pins GT_STATUS/In9] [get_bd_pins aurora_64b66b_0/link_reset_out]
  connect_bd_net -net aurora_64b66b_0_mmcm_not_locked_out [get_bd_pins GT_STATUS/In2] [get_bd_pins aurora_64b66b_0/mmcm_not_locked_out]
  connect_bd_net -net aurora_64b66b_0_soft_err [get_bd_pins GT_STATUS/In11] [get_bd_pins aurora_64b66b_0/soft_err]
  connect_bd_net -net cmac_usplus_0_gt_powergoodout [get_bd_pins GT_STATUS/In0] [get_bd_pins aurora_64b66b_0/gt_powergood]
  connect_bd_net -net concat_intc_dout [get_bd_ports intc] [get_bd_pins concat_intc/dout]
  connect_bd_net -net const_gnd_dout [get_bd_pins axi_timer_0/capturetrig0] [get_bd_pins axi_timer_0/capturetrig1] [get_bd_pins axi_timer_0/freeze] [get_bd_pins const_gnd/dout]
  connect_bd_net -net const_gndx14_dout [get_bd_pins GT_STATUS/In12] [get_bd_pins const_gndx14/dout]
  connect_bd_net -net eth_dma_mm2s_introut [get_bd_pins concat_intc/In0] [get_bd_pins eth_dma/mm2s_introut]
  connect_bd_net -net eth_dma_s2mm_introut [get_bd_pins concat_intc/In1] [get_bd_pins eth_dma/s2mm_introut]
  connect_bd_net -net gt_ctl_gpio_io_o [get_bd_pins aurora_64b66b_0/loopback] [get_bd_pins gt_ctl/gpio_io_o] [get_bd_pins gt_ctl_3/Din] [get_bd_pins gt_ctl_4/Din] [get_bd_pins gt_ctl_5/Din] [get_bd_pins gt_ctl_6/Din]
  connect_bd_net -net gt_rst_comb_Res [get_bd_pins aurora_64b66b_0/pma_init] [get_bd_pins gt_rst_comb/Res]
  connect_bd_net -net ext_rst_inv_Res [get_bd_pins ext_rst_inv/Res] [get_bd_pins gt_rst_comb/Op2]
  connect_bd_net -net gt_ctl_3_Dout [get_bd_pins aurora_64b66b_0/gt_rxcdrovrden_in] [get_bd_pins gt_ctl_3/Dout]
  connect_bd_net -net gt_ctl_4_Dout [get_bd_pins aurora_64b66b_0/power_down] [get_bd_pins gt_ctl_4/Dout]
  connect_bd_net -net gt_ctl_5_Dout [get_bd_pins aurora_64b66b_0/reset_pb] [get_bd_pins gt_ctl_5/Dout]
  connect_bd_net -net gt_ctl_6_Dout [get_bd_pins gt_ctl_6/Dout] [get_bd_pins gt_rst_comb/Op1]
if { ${g_dma_mem} eq "sram" } {
  connect_bd_net -net s_axi_clk_port [get_bd_ports s_axi_clk] [get_bd_pins aurora_64b66b_0/init_clk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins eth_dma/m_axi_sg_aclk] [get_bd_pins eth_dma/s_axi_lite_aclk] [get_bd_pins gt_ctl/s_axi_aclk] [get_bd_pins periph_connect/aclk] [get_bd_pins rx_axis_switch/s_axi_ctrl_aclk] [get_bd_pins rx_mem_cpu/s_axi_aclk] [get_bd_pins sg_mem_cpu/s_axi_aclk] [get_bd_pins sg_mem_dma/s_axi_aclk] [get_bd_pins tx_axis_switch/s_axi_ctrl_aclk] [get_bd_pins tx_mem_cpu/s_axi_aclk]
  connect_bd_net -net aurora_64b66b_0_user_clk_out [get_bd_pins aurora_64b66b_0/user_clk_out] [get_bd_pins eth_dma/m_axi_mm2s_aclk] [get_bd_pins eth_dma/m_axi_s2mm_aclk] [get_bd_pins rx_axis_switch/aclk] [get_bd_pins rx_mem_dma/s_axi_aclk] [get_bd_pins tx_axis_switch/aclk] [get_bd_pins tx_mem_dma/s_axi_aclk]
  connect_bd_net -net aurora_64b66b_0_gt_reset_out [get_bd_pins GT_STATUS/In8] [get_bd_pins aurora_64b66b_0/gt_reset_out]
  connect_bd_net -net aurora_64b66b_0_sys_reset_out [get_bd_pins GT_STATUS/In7] [get_bd_pins aur_sysrst_inv/Op1] [get_bd_pins aurora_64b66b_0/sys_reset_out]
  connect_bd_net -net aur_sysrst_inv_Res [get_bd_pins aur_sysrst_inv/Res] [get_bd_pins rx_axis_switch/aresetn] [get_bd_pins tx_axis_switch/aresetn] [get_bd_pins tx_mem_dma/s_axi_aresetn] [get_bd_pins rx_mem_dma/s_axi_aresetn]
  connect_bd_net -net s_axi_resetn_port [get_bd_ports s_axi_resetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins eth_dma/axi_resetn] [get_bd_pins ext_rst_inv/Op1] [get_bd_pins gt_ctl/s_axi_aresetn] [get_bd_pins periph_connect/aresetn] [get_bd_pins rx_axis_switch/s_axi_ctrl_aresetn] [get_bd_pins rx_mem_cpu/s_axi_aresetn] [get_bd_pins sg_mem_cpu/s_axi_aresetn] [get_bd_pins sg_mem_dma/s_axi_aresetn] [get_bd_pins tx_axis_switch/s_axi_ctrl_aresetn] [get_bd_pins tx_mem_cpu/s_axi_aresetn]
  connect_bd_net -net aurora_64b66b_0_gt_pll_lock [get_bd_pins GT_STATUS/In1] [get_bd_pins aurora_64b66b_0/gt_pll_lock]
}
if { ${g_dma_mem} eq "hbm" } {
  connect_bd_net -net s_axi_clk_port [get_bd_ports s_axi_clk] [get_bd_pins aurora_64b66b_0/init_clk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins dma_connect_sg/aclk] [get_bd_pins eth_dma/m_axi_sg_aclk] [get_bd_pins eth_dma/s_axi_lite_aclk] [get_bd_pins gt_ctl/s_axi_aclk] [get_bd_pins periph_connect/aclk] [get_bd_pins rx_axis_switch/s_axi_ctrl_aclk] [get_bd_pins tx_axis_switch/s_axi_ctrl_aclk]
  connect_bd_net -net aurora_64b66b_0_gt_reset_out [get_bd_pins GT_STATUS/In8] [get_bd_pins aurora_64b66b_0/gt_reset_out] [get_bd_pins txrx_rst_gen/mb_debug_sys_rst]
  connect_bd_net -net aurora_64b66b_0_sys_reset_out [get_bd_pins GT_STATUS/In7] [get_bd_pins aur_sysrst_inv/Op1] [get_bd_pins aurora_64b66b_0/sys_reset_out] [get_bd_pins txrx_rst_gen/aux_reset_in]
  connect_bd_net -net aurora_64b66b_0_user_clk_out [get_bd_ports rx_clk] [get_bd_ports tx_clk] [get_bd_pins aurora_64b66b_0/user_clk_out] [get_bd_pins axi_reg_slice_rx/aclk] [get_bd_pins axi_reg_slice_tx/aclk] [get_bd_pins dma_connect_rx/aclk] [get_bd_pins dma_connect_tx/aclk] [get_bd_pins eth_dma/m_axi_mm2s_aclk] [get_bd_pins eth_dma/m_axi_s2mm_aclk] [get_bd_pins rx_axis_switch/aclk] [get_bd_pins rx_fifo/s_axis_aclk] [get_bd_pins tx_axis_switch/aclk] [get_bd_pins txrx_rst_gen/slowest_sync_clk]
  connect_bd_net -net aur_sysrst_inv_Res [get_bd_pins aur_sysrst_inv/Res] [get_bd_pins dma_connect_rx/aresetn] [get_bd_pins dma_connect_tx/aresetn] [get_bd_pins rx_axis_switch/aresetn] [get_bd_pins rx_fifo/s_axis_aresetn] [get_bd_pins tx_axis_switch/aresetn]
  connect_bd_net -net s_axi_resetn_port [get_bd_ports s_axi_resetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins dma_connect_sg/aresetn] [get_bd_pins eth_dma/axi_resetn] [get_bd_pins ext_rst_inv/Op1] [get_bd_pins gt_ctl/s_axi_aresetn] [get_bd_pins periph_connect/aresetn] [get_bd_pins rx_axis_switch/s_axi_ctrl_aresetn] [get_bd_pins tx_axis_switch/s_axi_ctrl_aresetn] [get_bd_pins txrx_rst_gen/ext_reset_in]
  connect_bd_net -net rstint_0_Dout [get_bd_pins axi_reg_slice_tx/aresetn] [get_bd_pins rstint_0/Dout]
  connect_bd_net -net rstint_1_Dout [get_bd_pins axi_reg_slice_rx/aresetn] [get_bd_pins rstint_1/Dout]
  connect_bd_net -net rstext_0_Dout [get_bd_ports tx_rstn] [get_bd_pins rstext_0/Dout]
  connect_bd_net -net rstext_1_Dout [get_bd_ports rx_rstn] [get_bd_pins rstext_1/Dout]
  connect_bd_net -net txrx_rst_gen_interconnect_aresetn [get_bd_pins rstint_0/Din] [get_bd_pins rstint_1/Din] [get_bd_pins txrx_rst_gen/interconnect_aresetn]
  connect_bd_net -net txrx_rst_gen_peripheral_aresetn [get_bd_pins rstext_0/Din] [get_bd_pins rstext_1/Din] [get_bd_pins txrx_rst_gen/peripheral_aresetn]
  connect_bd_net -net aurora_64b66b_0_gt_pll_lock [get_bd_pins GT_STATUS/In1] [get_bd_pins aurora_64b66b_0/gt_pll_lock] [get_bd_pins txrx_rst_gen/dcm_locked]
}

  # Create address segments
  assign_bd_address -offset 0x00005000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs eth_dma/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00003000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs gt_ctl/S_AXI/Reg] -force
  assign_bd_address -offset 0x00002000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs rx_axis_switch/S_AXI_CTRL/Reg] -force
  assign_bd_address -offset 0x00001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs tx_axis_switch/S_AXI_CTRL/Reg] -force
if { ${g_dma_mem} eq "sram" } {
  assign_bd_address -offset 0x00000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces eth_dma/Data_S2MM] [get_bd_addr_segs rx_mem_dma/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x00040000 -target_address_space [get_bd_addr_spaces eth_dma/Data_SG] [get_bd_addr_segs sg_mem_dma/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces eth_dma/Data_MM2S] [get_bd_addr_segs tx_mem_dma/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00200000 -range 0x00080000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs rx_mem_cpu/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00300000 -range 0x00040000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs sg_mem_cpu/S_AXI/Mem0] -force
  assign_bd_address -offset 0x00100000 -range 0x00080000 -target_address_space [get_bd_addr_spaces s_axi] [get_bd_addr_segs tx_mem_cpu/S_AXI/Mem0] -force
}
if { ${g_dma_mem} eq "hbm" } {
  assign_bd_address -offset 0x00000000 -range 0x010000000000 -target_address_space [get_bd_addr_spaces eth_dma/Data_MM2S] [get_bd_addr_segs m_axi_tx/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x010000000000 -target_address_space [get_bd_addr_spaces eth_dma/Data_S2MM] [get_bd_addr_segs m_axi_rx/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x010000000000 -target_address_space [get_bd_addr_spaces eth_dma/Data_SG] [get_bd_addr_segs m_axi_sg/Reg] -force
}


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_aurora_dma()