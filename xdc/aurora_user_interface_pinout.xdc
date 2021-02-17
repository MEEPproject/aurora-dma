
 # Reference clock contraint for GTX
create_clock  -name gt_refclk1_in -period 6.400	 [get_ports GT_REFCLK1_P]
set_clock_groups -asynchronous -group [get_clocks gt_refclk1_in -include_generated_clocks]
  
set_property PACKAGE_PIN T43            [get_ports GT_REFCLK1_N]                 ;# Bank 134 - MGTREFCLK0N_134
set_property PACKAGE_PIN T42            [get_ports GT_REFCLK1_P]                 ;# Bank 134 - MGTREFCLK0P_134

# System clock pin

set_property PACKAGE_PIN BJ43            [get_ports GTY_SYSCLKP_I]                 ;# Bank 65 VCCO
set_property IOSTANDARD LVDS             [get_ports GTY_SYSCLKP_I]                 ;# Bank 65 VCCO
set_property PACKAGE_PIN BJ44            [get_ports GTY_SYSCLKN_I]                 ;# Bank 65 VCCO
set_property IOSTANDARD LVDS             [get_ports GTY_SYSCLKN_I]                 ;# Bank 65 VCCO



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

set_property PACKAGE_PIN D32              [get_ports HBM_CATTRIP]                        ;# Bank  75 VCCO - VCC1V8   - IO_L17P_T2U_N8_AD10P_75
set_property IOSTANDARD  LVCMOS18         [get_ports HBM_CATTRIP]                        ;# Bank  75 VCCO - VCC1V8   - IO_L17P_T2U_N8_AD10P_75