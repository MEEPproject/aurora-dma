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

# Author: Francelly Cano, BSC-CNS
# Date: 22.02.2022
# Description:
# Bitstream Configuration
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
# ------------------------------------------------------------------------
set_property PACKAGE_PIN D32              [get_ports HBM_CATTRIP]
set_property IOSTANDARD LVCMOS18          [get_ports HBM_CATTRIP]
set_property PULLTYPE PULLDOWN            [get_ports HBM_CATTRIP]
set_property PACKAGE_PIN BJ44             [get_ports SYS_CLK0_N]
set_property PACKAGE_PIN BJ43             [get_ports SYS_CLK0_P]
#set_property PACKAGE_PIN BJ6             [get_ports SYS_CLK1_N]
#set_property PACKAGE_PIN BH6              [get_ports SYS_CLK1_P]
#set_property PACKAGE_PIN F31              [get_ports {SYS_CLK3_N}]
#set_property IOSTANDARD  LVDS             [get_ports {SYS_CLK3_N}]
#set_property PACKAGE_PIN G31              [get_ports {SYS_CLK3_P}]
set_property IOSTANDARD LVDS              [get_ports {SYS_CLK*}]
#set_property PACKAGE_PIN L30              [get_ports RESETN]
#set_property IOSTANDARD LVCMOS18          [get_ports RESETN]
#set_property PACKAGE_PIN BH26             [get_ports PCIE_PERST]
#set_property IOSTANDARD LVCMOS18          [get_ports PCIE_PERST]
