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



# Script to generate C-header containing hardware definitions for Ethernet core

set bd_tcl [open $g_root_dir/tcl/aur_syst_bd.tcl             r]
set bd_hdr [open $g_root_dir/bd/$g_design_name/xparameters.h w]

puts $bd_hdr "#ifndef XPARAMETERS_H  // prevent circular inclusions"
puts $bd_hdr "#define XPARAMETERS_H  // by using protection macros"

puts $bd_hdr ""
puts $bd_hdr "// Some pre-definitions for Timer driver (needed as defines)"
puts $bd_hdr "#define XPAR_XTMRCTR_NUM_INSTANCES  1"
puts $bd_hdr "#define XPAR_TMRCTR_0_DEVICE_ID     0"
puts $bd_hdr "#define XPAR_TMRCTR_0_CLOCK_FREQ_HZ 100000000U"
puts $bd_hdr ""
puts $bd_hdr "enum {"

puts $bd_hdr "  // Some pre-definitions for DMA driver"
puts $bd_hdr "   XPAR_XAXIDMA_NUM_INSTANCES      = 1,"
puts $bd_hdr "   XPAR_AXIDMA_0_DEVICE_ID         = 0,"
puts $bd_hdr "   XPAR_AXIDMA_0_NUM_MM2S_CHANNELS = 1,"
puts $bd_hdr "   XPAR_AXIDMA_0_NUM_S2MM_CHANNELS = 1,"
puts $bd_hdr "   XPAR_AXI_DMA_0_MICRO_DMA        = 0,"
puts $bd_hdr "   XPAR_AXI_DMA_0_ADDR_WIDTH       = 32,"
puts $bd_hdr "  // Definitions extracted from Ethernet subsystem BD tcl script"
set comma_first 0
while {[gets $bd_tcl line] >= 0} {

  # extracting some DMA hw definitions
  if      {[string first "set eth_dma" $line] >= 0} {
    while {[string first  {] $eth_dma} $line] <  0} {
      gets $bd_tcl line
      if        {[string first "CONFIG.c_m_axis_mm2s_tdata_width"  $line] >= 0} {
        set line [string map  {"CONFIG.c_m_axis_mm2s_tdata_width" "ETH_DMA_AXIS_WIDTH ="}     $line]
      } elseif  {[string first "CONFIG.c_mm2s_burst_size"          $line] >= 0} {
        set line [string map  {"CONFIG.c_mm2s_burst_size" "XPAR_AXI_DMA_0_MM2S_BURST_SIZE ="} $line]
      } elseif  {[string first "CONFIG.c_s2mm_burst_size"          $line] >= 0} {
        set line [string map  {"CONFIG.c_s2mm_burst_size" "XPAR_AXI_DMA_0_S2MM_BURST_SIZE ="} $line]
      } elseif  {[string first "CONFIG.c_include_sg"               $line] >= 0} {
        set line [string map  {"CONFIG.c_include_sg" "XPAR_AXIDMA_0_INCLUDE_SG ="}            $line]
      } elseif  {[string first "CONFIG.c_sg_length_width"          $line] >= 0} {
        set line [string map  {"CONFIG.c_sg_length_width" "XPAR_AXIDMA_0_SG_LENGTH_WIDTH ="}  $line]
      } elseif  {[string first "CONFIG.c_sg_include_stscntrl_strm" $line] >= 0} {
        set line [string map  {"CONFIG.c_sg_include_stscntrl_strm" "XPAR_AXIDMA_0_SG_INCLUDE_STSCNTRL_STRM ="} $line]
      } elseif  {[string first "CONFIG.c_include_mm2s_dre"         $line] >= 0} {
        set line [string map  {"CONFIG.c_include_mm2s_dre"       "XPAR_AXIDMA_0_INCLUDE_MM2S_DRE ="} $line]
        set line [string map  {\} ", XPAR_AXIDMA_0_INCLUDE_MM2S = XPAR_AXIDMA_0_INCLUDE_MM2S_DRE"  } $line]
      } elseif  {[string first "CONFIG.c_include_s2mm_dre"         $line] >= 0} {
        set line [string map  {"CONFIG.c_include_s2mm_dre"       "XPAR_AXIDMA_0_INCLUDE_S2MM_DRE ="} $line]
        set line [string map  {\} ", XPAR_AXIDMA_0_INCLUDE_S2MM = XPAR_AXIDMA_0_INCLUDE_S2MM_DRE"  } $line]
      } elseif  {[string first "CONFIG.c_m_axi_mm2s_data_width"    $line] >= 0} {
        set line [string map  {"CONFIG.c_m_axi_mm2s_data_width"           "XPAR_AXIDMA_0_M_AXI_MM2S_DATA_WIDTH ="} $line]
        set line [string map  {\} ", XPAR_AXIDMA_0_M_AXI_S2MM_DATA_WIDTH = XPAR_AXIDMA_0_M_AXI_MM2S_DATA_WIDTH"  } $line]
      } else {
        continue
      }
      set line [string map {\{ "" \} "" \\ ","} $line]
      puts $bd_hdr $line
    }
    continue
  }

  # extracting some Ethernet core hw definitions
  if      {[string first "set eth100gb" $line] >= 0} {
    while {[string first  {] $eth100gb} $line] <  0} {
      gets $bd_tcl line
      if        {[string first "CONFIG.RX_MIN_PACKET_LEN" $line] >= 0} {
        set line [string map  {"CONFIG.RX_MIN_PACKET_LEN" "ETH_CORE_MIN_PACK_SIZE ="} $line]
      } elseif  {[string first "CONFIG.RX_MAX_PACKET_LEN" $line] >= 0} {
        set line [string map  {"CONFIG.RX_MAX_PACKET_LEN" "ETH_CORE_MAX_PACK_SIZE ="} $line]
      } else {
        continue
      }
      set line [string map {\{ "" \} "" \\ ","} $line]
      puts $bd_hdr $line
    }
    continue
  }

  # extracting address definitions
  if {[string first "get_bd_addr_segs axi_timer_0" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "XPAR_TMRCTR_0_BASEADDR ="}  $line]
    set line [string map {"-range"                    ", AXI_TIMER_0_ADRRANGE ="}    $line]
  } elseif {[string first "get_bd_addr_segs eth100gb" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "ETH100GB_BASEADDR ="}       $line]
    set line [string map {"-range"                    ", ETH100GB_ADRRANGE ="}       $line]
  } elseif {[string first "get_bd_addr_segs eth_dma" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "XPAR_AXIDMA_0_BASEADDR ="}  $line]
    set line [string map {"-range"                    ", ETH_DMA_ADRRANGE ="}        $line]
  } elseif {[string first "get_bd_addr_segs tx_axis_switch" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "TX_AXIS_SWITCH_BASEADDR ="} $line]
    set line [string map {"-range"                    ", TX_AXIS_SWITCH_ADRRANGE ="} $line]
  } elseif {[string first "get_bd_addr_segs rx_axis_switch" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "RX_AXIS_SWITCH_BASEADDR ="} $line]
    set line [string map {"-range"                    ", RX_AXIS_SWITCH_ADRRANGE ="} $line]
  } elseif {[string first "get_bd_addr_segs tx_mem_cpu" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "TX_MEM_CPU_BASEADDR ="}     $line]
    set line [string map {"-range"                    ", TX_MEM_CPU_ADRRANGE ="}     $line]
  } elseif {[string first "get_bd_addr_segs rx_mem_cpu" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "RX_MEM_CPU_BASEADDR ="}     $line]
    set line [string map {"-range"                    ", RX_MEM_CPU_ADRRANGE ="}     $line]
  } elseif {[string first "get_bd_addr_segs sg_mem_cpu" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "SG_MEM_CPU_BASEADDR ="}     $line]
    set line [string map {"-range"                    ", SG_MEM_CPU_ADRRANGE ="}     $line]
  } elseif {[string first "get_bd_addr_segs tx_rx_ctl_stat" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "TX_RX_CTL_STAT_BASEADDR ="} $line]
    set line [string map {"-range"                    ", TX_RX_CTL_STAT_ADRRANGE ="} $line]
  } elseif {[string first "get_bd_addr_segs gt_ctl" $line] >= 0} {
    set line [string map {"assign_bd_address -offset"   "GT_CTL_BASEADDR ="}         $line]
    set line [string map {"-range"                    ", GT_CTL_ADRRANGE ="}         $line]
  } else {
    continue
  }
  set line [string map {"-target_address_space"  "//"} $line]
  if {$comma_first} {
    puts -nonewline $bd_hdr "  ,"
  } else {
    puts -nonewline $bd_hdr "   "
  }
  puts $bd_hdr $line
  set comma_first 1
}

puts $bd_hdr "};"
puts $bd_hdr "#endif // end of protection macro"

close $bd_tcl
close $bd_hdr
