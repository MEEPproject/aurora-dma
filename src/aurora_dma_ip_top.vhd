// Title      : Aurora DMA IP implementation
// Project    : MEEP
// License    : <License type>
/*****************************************************************************/
// File        : aurora_dma_ip_top.vhd
// Author      : Francelly K. Cano Ladino; francelly.canoladino@bsc.es
// Company     : Barcelona Supercomputing Center (BSC)
// Created     : 12/08/2021 - 13:57:35
// Last update : 12/08/2021 - 13:57:35
/*****************************************************************************/
// Description: The Aurora DMA IP will perform an IP using all the necessaries extras IPs as: 
//              - Aurora 64B/66B IP core
//				- AXI DMA
//              - AXI4-Stream Subset converter   
//              - Reset_block
// Comments    : <Extra comments if they were needed>
/*****************************************************************************/
// Copyright (c) 2021 BSC
/*****************************************************************************/
// Revisions  :
// Date/Time                Version               Engineer
// dd/mm/yyyy - hh:mm        1.0             <contact email>
// Comments   : <Highlight the modifications>
/*****************************************************************************/

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_vector.all; 
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity aurora_dma_ip_top is
  port (
    
    ---------------------------------------
    -- AXI DMA
    ---------------------------------------                                    
    AXI_DMA_RESETN      : in  std_logic;
    S_AXI_LITE_DMA_ACLK : in  std_logic;
    
    --S_AXI_LITE
    S_AXI_LITE_DMA_ACLK : in  std_logic;
    S_AXI_LITE_ARADDR   : in  std_logic_vector (9 downto 0);
    S_AXI_LITE_ARREADY  : out std_logic;
    S_AXI_LITE_ARVALID  : in  std_logic;
    S_AXI_LITE_AWADDR   : in  std_logic_vector (9 downto 0);
    S_AXI_LITE_AWREADY  : out std_logic;
    S_AXI_LITE_AWVALID  : in  std_logic;
    S_AXI_LITE_BREADY   : in  std_logic;
    S_AXI_LITE_BRESP    : out std_logic_vector (1 downto 0);
    S_AXI_LITE_BVALID   : out std_logic;
    S_AXI_LITE_RDATA    : out std_logic_vector (31 downto 0);
    S_AXI_LITE_RREADY   : in  std_logic;
    S_AXI_LITE_RRESP    : out std_logic_vector (1 downto 0);
    S_AXI_LITE_RVALID   : out std_logic;
    S_AXI_LITE_WDATA    : in  std_logic_vector (31 downto 0);
    S_AXI_LITE_WREADY   : out std_logic;
    S_AXI_LITE_WVALID   : in  std_logic;

    --M_AXI_MM2S

    M_AXI_MM2S_ARADDR  : out std_logic_vector (31 downto 0);
    M_AXI_MM2S_ARBURST : out std_logic_vector (1 downto 0);
    M_AXI_MM2S_ARCACHE : out std_logic_vector (3 downto 0);
    M_AXI_MM2S_ARLEN   : out std_logic_vector (7 downto 0);
    M_AXI_MM2S_ARPROT  : out std_logic_vector (2 downto 0);
    M_AXI_MM2S_ARREADY : in  std_logic;
    M_AXI_MM2S_ARSIZE  : out std_logic_vector (2 downto 0);
    M_AXI_MM2S_ARVALID : out std_logic;
    M_AXI_MM2S_RDATA   : in  std_logic_vector (255 downto 0);
    M_AXI_MM2S_RLAST   : in  std_logic;
    M_AXI_MM2S_RREADY  : out std_logic;
    M_AXI_MM2S_RRESP   : in  std_logic_vector (1 downto 0);
    M_AXI_MM2S_RVALID  : in  std_logic;

    --M_AXI_S2MM

    M_AXI_S2MM_AWADDR  : out std_logic_vector (31 downto 0);
    M_AXI_S2MM_AWBURST : out std_logic_vector (1 downto 0);
    M_AXI_S2MM_AWCACHE : out std_logic_vector (3 downto 0);
    M_AXI_S2MM_AWLEN   : out std_logic_vector (7 downto 0);
    M_AXI_S2MM_AWPROT  : out std_logic_vector (2 downto 0);
    M_AXI_S2MM_AWREADY : in  std_logic;
    M_AXI_S2MM_AWSIZE  : out std_logic_vector (2 downto 0);
    M_AXI_S2MM_AWVALID : out std_logic;
    M_AXI_S2MM_BREADY  : out std_logic;
    M_AXI_S2MM_BRESP   : in  std_logic_vector (1 downto 0);
    M_AXI_S2MM_BVALID  : in  std_logic;
    M_AXI_S2MM_WDATA   : out std_logic_vector (255 downto 0);
    M_AXI_S2MM_WLAST   : out std_logic;
    M_AXI_S2MM_WREADY  : in  std_logic;
    M_AXI_S2MM_WSTRB   : out std_logic_vector (31 downto 0);
    M_AXI_S2MM_WVALID  : out std_logic;

    -- Interrupt
    MM2S_INTROUT          : out std_logic;
    MM2S_PRMRY_RESETN_OUT : out std_logic;
    S2MM_INTROUT          : out std_logic;
    S2MM_PRMRY_RESETN_OUT : out std_logic;
-------------------------------------------------------------------------------
-- Proc System Reset
-------------------------------------------------------------------------------
    
    PERIPHERAL_ARESETN : out std_logic_vector(0 downto 0);
    --Aurora_64B_66B
-------------------------------------------------------------------------------
-- Aurora 64B/66B core
-------------------------------------------------------------------------------
    --GT_REFCLK
    GT_REFCLK1_N : in std_logic;
    GT_REFCLK1_P : in std_logic;

    -- Core status
    CHANNEL_UP : out std_logic;
    LANE_UP    : out std_logic_vector (0 to 3);

    INIT_CLK     : in  std_logic;
    RESET        : in  std_logic;
    RESET_UI     : out std_logic;
    RXN          : in  std_logic_vector (0 to 3);
    RXP          : in  std_logic_vector (0 to 3);
    TXN          : out std_logic_vector (0 to 3);
    TXP          : out std_logic_vector (0 to 3);
    USER_CLK_OUT : out std_logic


    );
	
end entity aurora_dma_ip_top;

architecture rtl of aurora_dma_ip_top is

-------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------
-- Subset converter: DMA-to-Aurora

  signal dma_aurora_s_tvalid  : std_logic;
  signal dma_aurora_s_tready  : std_logic;
  signal dma_aurora_s_tdata   : std_logic_vector(255 downto 0);
  signal dma_aurora_s_tkeep   : std_logic_vector(31 downto 0);
  signal dma_aurora_s_tlast   : std_logic;
  signal dma_aurora_m_tvalid  : std_logic;
  signal dma_aurora_m_tready  : std_logic;
  signal dma_aurora_m_tdata   : std_logic_vector(255 downto 0);
  signal sparse_tkeep_removed : std_logic;

--Subset converter: Aurora-to-DMA

  signal aurora_dma_s_tvalid : std_logic;
  signal aurora_dma_s_tdata  : std_logic_vector(255 downto 0);
  signal aurora_dma_m_tvalid : std_logic;
  signal aurora_dma_m_tdata  : std_logic_vector(255 downto 0);
  signal aurora_dma_m_tkeep  : std_logic_vector(31 downto 0);
  signal aurora_dma_m_tlast  : std_logic;

-- Aurora core:
  signal user_clk_out                : std_logic;
  signal power_down                  : std_logic;
  signal lane_up_out                 : std_logic_vector(0 to 3);
  signal loopback                    : std_logic_vector(2 downto 0);
  signal hard_err                    : std_logic;
  signal soft_err                    : std_logic;
  signal channel_up_out              : std_logic;
  signal tx_out_clk                  : std_logic;
  signal gt_pll_lock                 : std_logic;
  signal mmcm_not_locked_out         : std_logic;
  signal gt0_drpaddr                 : std_logic_vector(9 downto 0);
  signal gt1_drpaddr                 : std_logic_vector(9 downto 0);
  signal gt2_drpaddr                 : std_logic_vector(9 downto 0);
  signal gt3_drpaddr                 : std_logic_vector(9 downto 0);
  signal gt0_drpdi                   : std_logic_vector(15 downto 0);
  signal gt1_drpdi                   : std_logic_vector(15 downto 0);
  signal gt2_drpdi                   : std_logic_vector(15 downto 0);
  signal gt3_drpdi                   : std_logic_vector(15 downto 0);
  signal gt0_drprdy                  : std_logic;
  signal gt1_drprdy                  : std_logic;
  signal gt2_drprdy                  : std_logic;
  signal gt3_drprdy                  : std_logic;
  signal gt0_drpwe                   : std_logic;
  signal gt1_drpwe                   : std_logic;
  signal gt2_drpwe                   : std_logic;
  signal gt3_drpwe                   : std_logic;
  signal gt0_drpen                   : std_logic;
  signal gt1_drpen                   : std_logic;
  signal gt2_drpen                   : std_logic;
  signal gt3_drpen                   : std_logic;
  signal gt0_drpdo                   : std_logic_vector(15 downto 0);
  signal gt1_drpdo                   : std_logic_vector(15 downto 0);
  signal gt2_drpdo                   : std_logic_vector(15 downto 0);
  signal gt3_drpdo                   : std_logic_vector(15 downto 0);
  signal link_reset_out              : std_logic;
  signal sync_clk_out                : std_logic;
  signal gt_qpllclk_quad1_out        : std_logic;
  signal gt_qpllrefclk_quad1_out     : std_logic;
  signal gt_qpllrefclklost_quad1_out : std_logic;
  signal gt_qplllock_quad1_out       : std_logic;
  signal gt_rxcdrovrden_in           : std_logic;
  signal sys_reset_out               : std_logic;
  signal gt_reset_out                : std_logic;
  signal gt_refclk1_out              : std_logic;
  signal gt_powergood                : std_logic_vector(3 downto 0);


-- proc system reset
  signal slowest_sync_clk     : std_logic;
  signal ext_reset_in         : std_logic;
  signal aux_reset_in         : std_logic;
  signal mb_debug_sys_rst     : std_logic;
  signal dcm_locked           : std_logic;
  signal mb_reset             : std_logic;
  signal bus_struct_reset     : std_logic_vector(0 downto 0);
  signal peripheral_reset     : std_logic_vector(0 downto 0);
  signal interconnect_aresetn : std_logic_vector(0 downto 0);

--Aurora component
COMPONENT aurora_64b66b_0
  PORT (
    rxp                         : in  std_logic_vector(0 to 3);
    rxn                         : in  std_logic_vector(0 to 3);
    reset_pb                    : in  std_logic;
    power_down                  : in  std_logic;
    pma_init                    : in  std_logic;
    loopback                    : in  std_logic_vector(2 downto 0);
    txp                         : out std_logic_vector(0 to 3);
    txn                         : out std_logic_vector(0 to 3);
    hard_err                    : out std_logic;
    soft_err                    : out std_logic;
    channel_up                  : out std_logic;
    lane_up                     : out std_logic_vector(0 to 3);
    tx_out_clk                  : out std_logic;
    gt_pll_lock                 : out std_logic;
    s_axi_tx_tdata              : in  std_logic_vector(255 downto 0);
    s_axi_tx_tvalid             : in  std_logic;
    s_axi_tx_tready             : out std_logic;
    m_axi_rx_tdata              : out std_logic_vector(255 downto 0);
    m_axi_rx_tvalid             : out std_logic;
    mmcm_not_locked_out         : out std_logic;
    gt0_drpaddr                 : in  std_logic_vector(9 downto 0);
    gt1_drpaddr                 : in  std_logic_vector(9 downto 0);
    gt2_drpaddr                 : in  std_logic_vector(9 downto 0);
    gt3_drpaddr                 : in  std_logic_vector(9 downto 0);
    gt0_drpdi                   : in  std_logic_vector(15 downto 0);
    gt1_drpdi                   : in  std_logic_vector(15 downto 0);
    gt2_drpdi                   : in  std_logic_vector(15 downto 0);
    gt3_drpdi                   : in  std_logic_vector(15 downto 0);
    gt0_drprdy                  : out std_logic;
    gt1_drprdy                  : out std_logic;
    gt2_drprdy                  : out std_logic;
    gt3_drprdy                  : out std_logic;
    gt0_drpwe                   : in  std_logic;
    gt1_drpwe                   : in  std_logic;
    gt2_drpwe                   : in  std_logic;
    gt3_drpwe                   : in  std_logic;
    gt0_drpen                   : in  std_logic;
    gt1_drpen                   : in  std_logic;
    gt2_drpen                   : in  std_logic;
    gt3_drpen                   : in  std_logic;
    gt0_drpdo                   : out std_logic_vector(15 downto 0);
    gt1_drpdo                   : out std_logic_vector(15 downto 0);
    gt2_drpdo                   : out std_logic_vector(15 downto 0);
    gt3_drpdo                   : out std_logic_vector(15 downto 0);
    init_clk                    : in  std_logic;
    link_reset_out              : out std_logic;
    gt_refclk1_p                : in  std_logic;
    gt_refclk1_n                : in  std_logic;
    user_clk_out                : out std_logic;
    sync_clk_out                : out std_logic;
    gt_qpllclk_quad1_out        : out std_logic;
    gt_qpllrefclk_quad1_out     : out std_logic;
    gt_qpllrefclklost_quad1_out : out std_logic;
    gt_qplllock_quad1_out       : out std_logic;
    gt_rxcdrovrden_in           : in  std_logic;
    sys_reset_out               : out std_logic;
    gt_reset_out                : out std_logic;
    gt_refclk1_out              : out std_logic;
    gt_powergood                : out std_logic_vector(3 downto 0)
  );
END COMPONENT;

-- AXI DMA

COMPONENT axi_dma_0
  PORT (
    s_axi_lite_aclk        : in  std_logic;
    m_axi_mm2s_aclk        : in  std_logic;
    m_axi_s2mm_aclk        : in  std_logic;
    axi_resetn             : in  std_logic;
    s_axi_lite_awvalid     : in  std_logic;
    s_axi_lite_awready     : out std_logic;
    s_axi_lite_awaddr      : in  std_logic_vector(9 downto 0);
    s_axi_lite_wvalid      : in  std_logic;
    s_axi_lite_wready      : out std_logic;
    s_axi_lite_wdata       : in  std_logic_vector(31 downto 0);
    s_axi_lite_bresp       : out std_logic_vector(1 downto 0);
    s_axi_lite_bvalid      : out std_logic;
    s_axi_lite_bready      : in  std_logic;
    s_axi_lite_arvalid     : in  std_logic;
    s_axi_lite_arready     : out std_logic;
    s_axi_lite_araddr      : in  std_logic_vector(9 downto 0);
    s_axi_lite_rvalid      : out std_logic;
    s_axi_lite_rready      : in  std_logic;
    s_axi_lite_rdata       : out std_logic_vector(31 downto 0);
    s_axi_lite_rresp       : out std_logic_vector(1 downto 0);
    m_axi_mm2s_araddr      : out std_logic_vector(31 downto 0);
    m_axi_mm2s_arlen       : out std_logic_vector(7 downto 0);
    m_axi_mm2s_arsize      : out std_logic_vector(2 downto 0);
    m_axi_mm2s_arburst     : out std_logic_vector(1 downto 0);
    m_axi_mm2s_arprot      : out std_logic_vector(2 downto 0);
    m_axi_mm2s_arcache     : out std_logic_vector(3 downto 0);
    m_axi_mm2s_arvalid     : out std_logic;
    m_axi_mm2s_arready     : in  std_logic;
    m_axi_mm2s_rdata       : in  std_logic_vector(255 downto 0);
    m_axi_mm2s_rresp       : in  std_logic_vector(1 downto 0);
    m_axi_mm2s_rlast       : in  std_logic;
    m_axi_mm2s_rvalid      : in  std_logic;
    m_axi_mm2s_rready      : out std_logic;
    mm2s_prmry_reset_out_n : out std_logic;
    m_axis_mm2s_tdata      : out std_logic_vector(255 downto 0);
    m_axis_mm2s_tkeep      : out std_logic_vector(31 downto 0);
    m_axis_mm2s_tvalid     : out std_logic;
    m_axis_mm2s_tready     : in  std_logic;
    m_axis_mm2s_tlast      : out std_logic;
    m_axi_s2mm_awaddr      : out std_logic_vector(31 downto 0);
    m_axi_s2mm_awlen       : out std_logic_vector(7 downto 0);
    m_axi_s2mm_awsize      : out std_logic_vector(2 downto 0);
    m_axi_s2mm_awburst     : out std_logic_vector(1 downto 0);
    m_axi_s2mm_awprot      : out std_logic_vector(2 downto 0);
    m_axi_s2mm_awcache     : out std_logic_vector(3 downto 0);
    m_axi_s2mm_awvalid     : out std_logic;
    m_axi_s2mm_awready     : in  std_logic;
    m_axi_s2mm_wdata       : out std_logic_vector(255 downto 0);
    m_axi_s2mm_wstrb       : out std_logic_vector(31 downto 0);
    m_axi_s2mm_wlast       : out std_logic;
    m_axi_s2mm_wvalid      : out std_logic;
    m_axi_s2mm_wready      : in  std_logic;
    m_axi_s2mm_bresp       : in  std_logic_vector(1 downto 0);
    m_axi_s2mm_bvalid      : in  std_logic;
    m_axi_s2mm_bready      : out std_logic;
    s2mm_prmry_reset_out_n : out std_logic;
    s_axis_s2mm_tdata      : in  std_logic_vector(255 downto 0);
    s_axis_s2mm_tkeep      : in  std_logic_vector(31 downto 0);
    s_axis_s2mm_tvalid     : in  std_logic;
    s_axis_s2mm_tready     : out std_logic;
    s_axis_s2mm_tlast      : in  std_logic;
    mm2s_introut           : out std_logic;
    s2mm_introut           : out std_logic;
    axi_dma_tstvec         : out std_logic_vector(31 downto 0)
  );
END COMPONENT;

-- Aurora-to-DMA
COMPONENT axis_subset_converter_0
  PORT (
    aclk          : in  std_logic;
    aresetn       : in  std_logic;
    s_axis_tvalid : in  std_logic;
    s_axis_tdata  : in  std_logic_vector(255 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tdata  : out std_logic_vector(255 downto 0);
    m_axis_tkeep  : out std_logic_vector(31 downto 0);
    m_axis_tlast  : out std_logic
  );
END COMPONENT;

--DMA-to-Aurora
COMPONENT axis_subset_converter_1
  port (
    aclk                 : in  std_logic;
    aresetn              : in  std_logic;
    s_axis_tvalid        : in  std_logic;
    s_axis_tready        : out std_logic;
    s_axis_tdata         : in  std_logic_vector(255 downto 0);
    s_axis_tkeep         : in  std_logic_vector(31 downto 0);
    s_axis_tlast         : in  std_logic;
    m_axis_tvalid        : out std_logic;
    m_axis_tready        : in  std_logic;
    m_axis_tdata         : out std_logic_vector(255 downto 0);
    sparse_tkeep_removed : out std_logic
  );
END COMPONENT;

-- Processor System Reset
COMPONENT proc_sys_reset_0
  PORT (
    slowest_sync_clk     : in  std_logic;
    ext_reset_in         : in  std_logic;
    aux_reset_in         : in  std_logic;
    mb_debug_sys_rst     : in  std_logic;
    dcm_locked           : in  std_logic;
    mb_reset             : out std_logic;
    bus_struct_reset     : out std_logic_vector(0 downto 0);
    peripheral_reset     : out std_logic_vector(0 downto 0);
    interconnect_aresetn : out std_logic_vector(0 downto 0);
    peripheral_aresetn   : out std_logic_vector(0 downto 0)
  );
END COMPONENT;


begin
-- Reset Block

reset_ui_aux<=RESET_UI;
reset_0 : entity work.reset_block
generic map (
  INITCLOCK_FREQ_MHZ => INITCLOCK_FREQ_MHZ)
port map (
  INIT_CLK   => INIT_CLK,
  RESET      => RESET,
  CHANNEL_UP => CHANNEL_UP,
  SYS_RESET  => SYS_RESET,
  PMA_INIT   => PMA_INIT,
  RESET_PB   => RESET_PB,
  RESET_UI   => RESET_UI);




-- AXI DMA instance 
axi_dma : axi_dma_0
  port map (
    s_axi_lite_aclk        => S_AXI_LITE_DMA_ACLK,
    m_axi_mm2s_aclk        => USER_CLK_OUT,
    m_axi_s2mm_aclk        => USER_CLK_OUT,
    axi_resetn             => AXI_DMA_RESETN,
    s_axi_lite_awvalid     => S_AXI_LITE_AWVALID,
    s_axi_lite_awready     => S_AXI_LITE_AWREADY,
    s_axi_lite_awaddr      => S_AXI_LITE_AWADDR,
    s_axi_lite_wvalid      => S_AXI_LITE_WVALID,
    s_axi_lite_wready      => S_AXI_LITE_WREADY,
    s_axi_lite_wdata       => S_AXI_LITE_WDATA,
    s_axi_lite_bresp       => S_AXI_LITE_BRESP,
    s_axi_lite_bvalid      => S_AXI_LITE_BVALID,
    s_axi_lite_bready      => S_AXI_LITE_BREADY,
    s_axi_lite_arvalid     => S_AXI_LITE_ARVALID,
    s_axi_lite_arready     => S_AXI_LITE_ARREADY,
    s_axi_lite_araddr      => S_AXI_LITE_ARADDR,
    s_axi_lite_rvalid      => S_AXI_LITE_RVALID,
    s_axi_lite_rready      => S_AXI_LITE_RREADY,
    s_axi_lite_rdata       => S_AXI_LITE_RDATA,
    s_axi_lite_rresp       => S_AXI_LITE_RRESP,
    m_axi_mm2s_araddr      => M_AXI_MM2S_ARADDR,
    m_axi_mm2s_arlen       => M_AXI_MM2S_ARLEN,
    m_axi_mm2s_arsize      => M_AXI_MM2S_ARSIZE,
    m_axi_mm2s_arburst     => M_AXI_MM2S_ARBURST,
    m_axi_mm2s_arprot      => M_AXI_MM2S_ARPROT,
    m_axi_mm2s_arcache     => M_AXI_MM2S_ARCACHE,
    m_axi_mm2s_arvalid     => M_AXI_MM2S_ARVALID,
    m_axi_mm2s_arready     => M_AXI_MM2S_ARREADY,
    m_axi_mm2s_rdata       => M_AXI_MM2S_RDATA,
    m_axi_mm2s_rresp       => M_AXI_MM2S_RRESP,
    m_axi_mm2s_rlast       => M_AXI_MM2S_RLAST,
    m_axi_mm2s_rvalid      => M_AXI_MM2S_RVALID,
    m_axi_mm2s_rready      => M_AXI_MM2S_RREADY,
    mm2s_prmry_reset_out_n => MM2S_PRMRY_RESETN_OUT,
    m_axis_mm2s_tdata      => dma_aurora_s_tdata,
    m_axis_mm2s_tkeep      => dma_aurora_s_tkeep,
    m_axis_mm2s_tvalid     => dma_aurora_s_tvalid,
    m_axis_mm2s_tready     => dma_aurora_s_tready,
    m_axis_mm2s_tlast      => dma_aurora_s_tlast,
    m_axi_s2mm_awaddr      => M_AXI_S2MM_AWADDR,
    m_axi_s2mm_awlen       => M_AXI_S2MM_AWLEN,
    m_axi_s2mm_awsize      => M_AXI_S2MM_AWSIZE,
    m_axi_s2mm_awburst     => M_AXI_S2MM_AWBURST,
    m_axi_s2mm_awprot      => M_AXI_S2MM_AWPROT,
    m_axi_s2mm_awcache     => M_AXI_S2MM_AWCACHE,
    m_axi_s2mm_awvalid     => M_AXI_S2MM_AWVALID,
    m_axi_s2mm_awready     => M_AXI_S2MM_AWREADY,
    m_axi_s2mm_wdata       => M_AXI_S2MM_WDATA,
    m_axi_s2mm_wstrb       => M_AXI_S2MM_WSTRB,
    m_axi_s2mm_wlast       => M_AXI_S2MM_WLAST,
    m_axi_s2mm_wvalid      => M_AXI_S2MM_WVALID,
    m_axi_s2mm_wready      => M_AXI_S2MM_WREADY,
    m_axi_s2mm_bresp       => M_AXI_S2MM_BRESP,
    m_axi_s2mm_bvalid      => M_AXI_S2MM_BVALID,
    m_axi_s2mm_bready      => M_AXI_S2MM_BREADY,
    s2mm_prmry_reset_out_n => S2MM_PRMRY_RESETN_OUT,
    s_axis_s2mm_tdata      => aurora_dma_m_tdata,
    s_axis_s2mm_tkeep      => aurora_dma_m_tdata,
    s_axis_s2mm_tvalid     => aurora_dma_m_tvalid,
    s_axis_s2mm_tready     => aurora_dma_m_tready,
    s_axis_s2mm_tlast      => aurora_dma_m_tlast,
    mm2s_introut           => MM2S_INTROUT,
    s2mm_introut           => S2MM_INTROUT,
    axi_dma_tstvec         => axi_dma_tstvec
    );

-- Aurora 64B/66B
-------------------------------------------------------------------------------
-- Aurora Core instantiation
-------------------------------------------------------------------------------
--Auxiliary signals  assign to 'GND' if they are not unused
power_down        <= '0';
gt_rxcdrovrden_in <= '0';
loopback          <= (others => '0');
gt0_drpaddr       <= (others => '0');
gt1_drpaddr       <= (others => '0');
gt2_drpaddr       <= (others => '0');
gt3_drpaddr       <= (others => '0');
gt0_drpdi         <= (others => '0');
gt1_drpdi         <= (others => '0');
gt2_drpdi         <= (others => '0');
gt3_drpdi         <= (others => '0');
gt0_drpen         <= '0';
gt1_drpen         <= '0';
gt2_drpen         <= '0';
gt3_drpen         <= '0';
gt0_drpwe         <= '0';
gt1_drpwe         <= '0';
gt2_drpwe         <= '0';
gt3_drpwe         <= '0';
----------------------------


aurora_core : aurora_64b66b_0
  port map (
    rxp                         => RXP,
    rxn                         => RXN,
    reset_pb                    => RESET_PB,
    power_down                  => power_down,
    pma_init                    => PMA_INIT,
    loopback                    => loopback,
    txp                         => TXP,
    txn                         => TXN,
    hard_err                    => hard_err,
    soft_err                    => soft_err,
    channel_up                  => CHANNEL_UP,
    lane_up                     => LANE_UP,
    tx_out_clk                  => tx_out_clk,
    gt_pll_lock                 => gt_pll_lock,
    s_axi_tx_tdata              => dma_aurora_m_tdata,
    s_axi_tx_tvalid             => dma_aurora_m_tvalid,
    s_axi_tx_tready             => dma_aurora_m_tready,
    m_axi_rx_tdata              => aurora_dma_s_tdata,
    m_axi_rx_tvalid             => aurora_dma_s_tvalid,
    mmcm_not_locked_out         => mmcm_not_locked_out,
    gt0_drpaddr                 => gt0_drpaddr,
    gt1_drpaddr                 => gt1_drpaddr,
    gt2_drpaddr                 => gt2_drpaddr,
    gt3_drpaddr                 => gt3_drpaddr,
    gt0_drpdi                   => gt0_drpdi,
    gt1_drpdi                   => gt1_drpdi,
    gt2_drpdi                   => gt2_drpdi,
    gt3_drpdi                   => gt3_drpdi,
    gt0_drprdy                  => gt0_drprdy,
    gt1_drprdy                  => gt1_drprdy,
    gt2_drprdy                  => gt2_drprdy,
    gt3_drprdy                  => gt3_drprdy,
    gt0_drpwe                   => gt0_drpwe,
    gt1_drpwe                   => gt1_drpwe,
    gt2_drpwe                   => gt2_drpwe,
    gt3_drpwe                   => gt3_drpwe,
    gt0_drpen                   => gt0_drpen,
    gt1_drpen                   => gt1_drpen,
    gt2_drpen                   => gt2_drpen,
    gt3_drpen                   => gt3_drpen,
    gt0_drpdo                   => gt0_drpdo,
    gt1_drpdo                   => gt1_drpdo,
    gt2_drpdo                   => gt2_drpdo,
    gt3_drpdo                   => gt3_drpdo,
    init_clk                    => INIT_CLK,
    link_reset_out              => link_reset_out,
    gt_refclk1_p                => GT_REFCLK1_P,
    gt_refclk1_n                => GT_REFCLK1_N,
    user_clk_out                => USER_CLK_OUT,
    sync_clk_out                => sync_clk_out,
    gt_qpllclk_quad1_out        => gt_qpllclk_quad1_out,
    gt_qpllrefclk_quad1_out     => gt_qpllrefclk_quad1_out,
    gt_qpllrefclklost_quad1_out => gt_qpllrefclklost_quad1_out,
    gt_qplllock_quad1_out       => gt_qplllock_quad1_out,
    gt_rxcdrovrden_in           => gt_rxcdrovrden_in,
    sys_reset_out               => SYS_RESET_OUT,
    gt_reset_out                => gt_reset_out,
    gt_refclk1_out              => gt_refclk1_out,
    gt_powergood                => gt_powergood
    );

aurora_dma : axis_subset_converter_0
  port map (
    aclk          => aclk,
    aresetn       => aresetn,
    s_axis_tvalid => aurora_dma_s_tvalid,
    s_axis_tdata  => aurora_dma_s_tdata,
    m_axis_tvalid => aurora_dma_m_tvalid,
    m_axis_tdata  => aurora_dma_m_tdata,
    m_axis_tkeep  => aurora_dma_m_tkeep,
    m_axis_tlast  => aurora_dma_m_tlast
    );
  

dma_aurora : axis_subset_converter_1
  port map (
    aclk                 => aclk,
    aresetn              => aresetn,
    s_axis_tvalid        => dma_aurora_s_tvalid,
    s_axis_tready        => dma_aurora_s_tready,
    s_axis_tdata         => dma_aurora_s_tdata,
    s_axis_tkeep         => dma_aurora_s_tkeep,
    s_axis_tlast         => dma_aurora_s_tlast,
    m_axis_tvalid        => dma_aurora_s_tvalid,
    m_axis_tready        => dma_aurora_m_tready,
    m_axis_tdata         => dma_aurora_m_tdata,
    sparse_tkeep_removed => sparse_tkeep_removed
    );

ext_reset_in <= not reset_ui_aux;
proc_system_reset : proc_sys_reset_0
  port map (
    slowest_sync_clk     => USER_CLK_OUT,
    ext_reset_in         => ext_reset_in,
    aux_reset_in         => aux_reset_in,
    mb_debug_sys_rst     => mb_debug_sys_rst,
    dcm_locked           => dcm_locked,
    mb_reset             => mb_reset,
    bus_struct_reset     => bus_struct_reset,
    peripheral_reset     => peripheral_reset,
    interconnect_aresetn => interconnect_aresetn,
    peripheral_aresetn   => peripheral_aresetn
    );

  end architecture rtl;
