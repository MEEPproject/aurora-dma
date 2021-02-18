-------------------------------------------------------------------------------
-- Title      : User Interface
-- Project    : MEEP
-------------------------------------------------------------------------------
-- File        : user_interface_top.vhd
-- Author      : Francelly K. Cano Ladino; francelly.canoladino@bsc.es
-- Company     : Barcelona Supercomputing Center (BSC)
-- Created     : 19/01/2021 - 19:12:35
-- Last update : Mon Feb 15 15:03:07 2021
-- Synthesizer : <Name> <version>
-- FPGA        : Alveo U280
-------------------------------------------------------------------------------
-- Description: User interface /Aurora64B/66B. First shot
--
-- Comments    : <Extra comments if they were needed>
-------------------------------------------------------------------------------
-- Copyright (c) 2019 DDR/TICH
-------------------------------------------------------------------------------
-- Revisions  : 1.0
-- Date/Time                Version               Engineer
-- dd/mm/yyyy - hh:mm        1.0             francelly.canoladino@bsc.es
-- Comments   : <Highlight the modifications>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;



entity aurora_user_interface_top is
  generic (
    EXAMPLE_SIMULATION : integer := 0);
  port (

    -------------------------------------------------------------------------------
    -- System Interface
    -------------------------------------------------------------------------------     
    RESET       : in std_logic;
    ----------------------------------------------------------------------------
    -- GT DIFF REFCLK
    ----------------------------------------------------------------------------
    GT_REFCLK1_N : in  std_logic;
    GT_REFCLK1_P : in  std_logic;
    -------------------------------------------------------------------------------
    -- INIT_CLK: Clock wizard
    -------------------------------------------------------------------------------
    RESETN       : in std_logic;        
    GTY_SYSCLKP_I: in std_logic;  
    GTY_SYSCLKN_I: in std_logic; 
    ----------------------------------------------------------------------------
    -- GT SERIAL TX
    ----------------------------------------------------------------------------
    TXN : out std_logic_vector(0 downto 0);
    TXP : out std_logic_vector(0 downto 0);
    ----------------------------------------------------------------------------
    -- GT SERIAL RX
    ----------------------------------------------------------------------------
    RXN : in std_logic_vector(0 downto 0);
    RXP : in std_logic_vector(0 downto 0);
    ----------------------------------------------------------------------------
    
    HBM_CATTRIP    : out std_logic
    );

end entity aurora_user_interface_top;

architecture rtl of aurora_user_interface_top is
--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------
  -- component generics
  constant DATA_WIDTH : integer := 64;
  constant STRB_WIDTH : integer := 8;
-------------------------------------------------------------------------------
-- User interface: 
-------------------------------------------------------------------------------

  signal axis_ui_tx_tdata  : std_logic_vector(63 downto 0);
  signal axis_ui_tx_tvalid : std_logic;
  signal axis_ui_tx_tready : std_logic;
  signal axis_ui_rx_tdata  : std_logic_vector(63 downto 0);
  signal axis_ui_rx_tvalid : std_logic;
  signal reset_fg          : std_logic;
  signal reset_fc          : std_logic;
  signal pma_init          : std_logic;
  signal reset_pb          : std_logic;  
  signal init_clk_in       : std_logic;
  signal reset_i           : std_logic;
  signal reset_h           : std_logic;
  signal data_err_count    : std_logic_vector(7 downto 0);
---------------------------------------------------------------------------------
  -- Aurora core: 
  -------------------------------------------------------------------------------
  signal user_clk_out                : std_logic;
  signal power_down                  : std_logic;
  signal lane_up_out                 : std_logic_vector(0 downto 0);
  signal loopback                    : std_logic_vector(2 downto 0);
  signal hard_err                    : std_logic;
  signal soft_err                    : std_logic;
  signal channel_up_out              : std_logic;
  signal tx_out_clk                  : std_logic;
  signal gt_pll_lock                 : std_logic;
  signal mmcm_not_locked_out         : std_logic;
  signal gt0_drpaddr                 : std_logic_vector(9 downto 0);
  signal gt0_drpdi                   : std_logic_vector(15 downto 0);
  signal gt0_drprdy                  : std_logic;
  signal gt0_drpwe                   : std_logic;
  signal gt0_drpen                   : std_logic;
  signal gt0_drpdo                   : std_logic_vector(15 downto 0);
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
  signal gt_powergood                : std_logic_vector(0 downto 0);
 ------------------------------------------------------------------------------


  component aurora_64b66b_0
    port (
      rxp                         : in  std_logic_vector(0 downto 0);
      rxn                         : in  std_logic_vector(0 downto 0);
      reset_pb                    : in  std_logic;
      power_down                  : in  std_logic;
      pma_init                    : in  std_logic;
      loopback                    : in  std_logic_vector(2 downto 0);
      txp                         : out std_logic_vector(0 downto 0);
      txn                         : out std_logic_vector(0 downto 0);
      hard_err                    : out std_logic;
      soft_err                    : out std_logic;
      channel_up                  : out std_logic;
      lane_up                     : out std_logic_vector(0 downto 0);
      tx_out_clk                  : out std_logic;
      gt_pll_lock                 : out std_logic;
      s_axi_tx_tdata              : in  std_logic_vector(63 downto 0);
      s_axi_tx_tvalid             : in  std_logic;
      s_axi_tx_tready             : out std_logic;
      m_axi_rx_tdata              : out std_logic_vector(63 downto 0);
      m_axi_rx_tvalid             : out std_logic;
      mmcm_not_locked_out         : out std_logic;
      gt0_drpaddr                 : in  std_logic_vector(9 downto 0);
      gt0_drpdi                   : in  std_logic_vector(15 downto 0);
      gt0_drprdy                  : out std_logic;
      gt0_drpwe                   : in  std_logic;
      gt0_drpen                   : in  std_logic;
      gt0_drpdo                   : out std_logic_vector(15 downto 0);
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
      gt_powergood                : out std_logic_vector(0 downto 0)
      );
  end component;
-------------------------------------------------------------------------------
  component vio_0
    port (
      clk        : in  std_logic;
      probe_out0 : out std_logic_vector(0 downto 0)
      );
  end component;
 ------------------------------------------------------------------------------
component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  resetn            : in     std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;
-------------------------------------------------------------------------------
 --Add mark_debug attributes to show debug nets in the synthesized netlist
attribute keep        : string;
attribute mark_debug  : string;

attribute keep of channel_up_out     : signal is "true";
attribute keep of lane_up_out        : signal is "true";
attribute keep of axis_ui_tx_tdata   : signal is "true";
attribute keep of axis_ui_tx_tvalid  : signal is "true";
attribute keep of axis_ui_tx_tready  : signal is "true";
attribute keep of axis_ui_rx_tdata   : signal is "true";
attribute keep of axis_ui_rx_tvalid  : signal is "true";
attribute keep of data_err_count     : signal is "true";

attribute mark_debug of channel_up_out     : signal is "true";
attribute mark_debug of lane_up_out        : signal is "true";
attribute mark_debug of axis_ui_tx_tdata   : signal is "true";
attribute mark_debug of axis_ui_tx_tvalid  : signal is "true";
attribute mark_debug of axis_ui_tx_tready  : signal is "true";
attribute mark_debug of axis_ui_rx_tdata   : signal is "true";
attribute mark_debug of axis_ui_rx_tvalid  : signal is "true";
attribute mark_debug of data_err_count     : signal is "true";

--COMPONENT ila_0
--PORT (
--	clk : IN STD_LOGIC;
--	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--	probe2 : IN STD_LOGIC_VECTOR(63 DOWNTO 0); 
--	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--	probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
--	probe5 : IN STD_LOGIC_VECTOR(63 DOWNTO 0); 
--	probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--	probe7 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
--);
--END COMPONENT  ;
begin

HBM_CATTRIP<='0';
------------------------------------------------------------------------------

 clock_wizard_0 : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => init_clk_in,
  -- Status and control signals                
   resetn => RESETN,
   -- Clock in ports
   clk_in1_p => GTY_SYSCLKP_I,
   clk_in1_n => GTY_SYSCLKN_I
 );
-------------------------------------------------------------------------------
-- Frame_Gen instantiation
-------------------------------------------------------------------------------
  framegen_0 : entity work.frame_gen
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      STRB_WIDTH => STRB_WIDTH)
    port map (
      USER_CLK          => user_clk_out,
      RESET             => reset_fg,
      AXIS_UI_TX_TDATA  => axis_ui_tx_tdata,
      AXIS_UI_TX_TVALID => axis_ui_tx_tvalid,
      AXIS_UI_TX_TREADY => axis_ui_tx_tready);

-------------------------------------------------------------------------------
 --Frame Checker instantiation
 -------------------------------------------------------------------------------  
  framecheck_0 : entity work.frame_check
    port map (
      USER_CLK          => user_clk_out,
      RESET             => reset_fc,
      AXIS_UI_RX_TDATA  => axis_ui_rx_tdata,
      AXIS_UI_RX_TVALID => axis_ui_rx_tvalid,
      DATA_ERR_COUNT    => data_err_count);

-------------------------------------------------------------------------------
-- Reset block instantiation
-------------------------------------------------------------------------------
 --Comes from VIO_0
  g_hard : if EXAMPLE_SIMULATION = 0 generate
    reset_i<=reset_h;  
  end generate g_hard;
  
  g_sim : if EXAMPLE_SIMULATION = 1 generate
    reset_i<=RESET;
  end generate g_sim;
  reset_0 : entity work.reset_block
    port map (
      INIT_CLK   => init_clk_in,
      RESET      => reset_i,
      CHANNEL_UP => channel_up_out,
      SYS_RESET  => sys_reset_out,
      PMA_INIT   => pma_init,
      RESET_PB   => reset_pb,
      RESET_FG   => reset_fg,
      RESET_FC   => reset_fc);

-------------------------------------------------------------------------------
-- Aurora Core instantiation
-------------------------------------------------------------------------------
--Auxiliary signals  assign to 'GND' if they are not unused
  power_down        <= '0';
  gt_rxcdrovrden_in <= '0';
  loopback          <= (others => '0');
  gt0_drpaddr       <= (others => '0');
  gt0_drpdi         <= (others => '0');
  gt0_drpen         <= '0';
  gt0_drpwe         <= '0';
  --------------------------------------------------------------------------


  aurora_0 : aurora_64b66b_0
    port map (
      rxp                         => RXP,
      rxn                         => RXN,
      reset_pb                    => reset_pb,
      power_down                  => power_down,
      pma_init                    => pma_init,
      loopback                    => loopback,
      txp                         => TXP,
      txn                         => TXN,
      hard_err                    => hard_err,
      soft_err                    => soft_err,
      channel_up                  => channel_up_out,
      lane_up                     => lane_up_out,
      tx_out_clk                  => tx_out_clk,
      gt_pll_lock                 => gt_pll_lock,
      s_axi_tx_tdata              => axis_ui_tx_tdata,
      s_axi_tx_tvalid             => axis_ui_tx_tvalid,
      s_axi_tx_tready             => axis_ui_tx_tready,
      m_axi_rx_tdata              => axis_ui_rx_tdata,
      m_axi_rx_tvalid             => axis_ui_rx_tvalid,
      mmcm_not_locked_out         => mmcm_not_locked_out,
      gt0_drpaddr                 => gt0_drpaddr,
      gt0_drpdi                   => gt0_drpdi,
      gt0_drprdy                  => gt0_drprdy,
      gt0_drpwe                   => gt0_drpwe,
      gt0_drpen                   => gt0_drpen,
      gt0_drpdo                   => gt0_drpdo,
      init_clk                    => init_clk_in,
      link_reset_out              => link_reset_out,
      gt_refclk1_p                => GT_REFCLK1_P,
      gt_refclk1_n                => GT_REFCLK1_N,
      user_clk_out                => user_clk_out,
      sync_clk_out                => sync_clk_out,
      gt_qpllclk_quad1_out        => gt_qpllclk_quad1_out,
      gt_qpllrefclk_quad1_out     => gt_qpllrefclk_quad1_out,
      gt_qpllrefclklost_quad1_out => gt_qpllrefclklost_quad1_out,
      gt_qplllock_quad1_out       => gt_qplllock_quad1_out,
      gt_rxcdrovrden_in           => gt_rxcdrovrden_in,
      sys_reset_out               => sys_reset_out,
      gt_reset_out                => gt_reset_out,
      gt_refclk1_out              => gt_refclk1_out,
      gt_powergood                => gt_powergood
      );
-------------------------------------------------------------------------------
-- VIO 
-------------------------------------------------------------------------------
  vio_1 : vio_0
    port map (
      clk           => init_clk_in,
      probe_out0(0) => reset_h
      );
-------------------------------------------------------------------------------
-- ILA
-------------------------------------------------------------------------------
      
--ila_1: ila_0
--PORT MAP (
--	clk => user_clk_out,
--	probe0(0) => channel_up_out, 
--	probe1 => lane_up_out, 
--	probe2 => axis_ui_tx_tdata, 
--	probe3(0) => axis_ui_tx_tvalid, 
--	probe4(0) => axis_ui_tx_tready, 
--	probe5 => axis_ui_rx_tdata, 
--	probe6(0) => axis_ui_rx_tvalid,
--	probe7 => data_err_count
--);
end architecture rtl;
