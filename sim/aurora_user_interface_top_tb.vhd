-------------------------------------------------------------------------------
-- Title      : User Interface
-- Project    : MEEP
-------------------------------------------------------------------------------
-- File        : user_interface_top.vhd
-- Author      : Francelly K. Cano Ladino; francelly.canoladino@bsc.es
-- Company     : Barcelona Supercomputing Center (BSC)
-- Created     : 15/02/2021 - 16:55:02
-- Last update : Mon Feb 15 17:04:50 2021
-- Synthesizer : <Name> <version>
-- FPGA        : Alveo U280
-------------------------------------------------------------------------------
-- Description: User interface /Aurora64B/66B. 
-- In this testbench, we want to test two instance of aurora_user_interface 
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

-------------------------------------------------------------------------------

entity aurora_user_interface_top_tb is

end entity aurora_user_interface_top_tb;

-------------------------------------------------------------------------------

architecture testbench of aurora_user_interface_top_tb is

  -- component generics
  constant EXAMPLE_SIMULATION : integer := 1;

  -- component ports
  signal RESET          : std_logic;
  signal GT_REFCLK1_N   : std_logic;
  signal GT_REFCLK1_P   : std_logic;
  signal RESETN         : std_logic;
  signal GTY_SYSCLKP_I  : std_logic;
  signal GTY_SYSCLKN_I  : std_logic;  
  signal TXN_0          : std_logic_vector(0 downto 0);
  signal TXP_0          : std_logic_vector(0 downto 0);
  signal TXN_1          : std_logic_vector(0 downto 0);
  signal TXP_1          : std_logic_vector(0 downto 0);
  signal RXN_0          : std_logic_vector(0 downto 0);
  signal RXP_0          : std_logic_vector(0 downto 0);
  signal RXN_1          : std_logic_vector(0 downto 0);
  signal RXP_1          : std_logic_vector(0 downto 0);
  signal HBM_CATTRIP    : std_logic;
  -- clock

  constant Tclk_init  : time := 10 ns;--6.206 ns;
  constant Tclk_gtRef : time := 6.4 ns;

begin  -- architecture testbench

-- User interface:
--System 1
  RXN_0 <= TXN_1;
  RXP_0 <= TXP_1;
--System 2
  RXN_1 <= TXN_0;
  RXP_1 <= TXP_0;

  -- component instantiation
  DUT_0 : entity work.aurora_user_interface_top
    generic map (
      EXAMPLE_SIMULATION => EXAMPLE_SIMULATION)
    port map (
      RESET          => RESET,
      GT_REFCLK1_N   => GT_REFCLK1_N,
      GT_REFCLK1_P   => GT_REFCLK1_P,
      RESETN         => RESETN,
      GTY_SYSCLKP_I  => GTY_SYSCLKP_I,
      GTY_SYSCLKN_I  => GTY_SYSCLKN_I,
      TXN            => TXN_0,
      TXP            => TXP_0,
      RXN            => RXN_0,
      RXP            => RXP_0,      
      HBM_CATTRIP    => HBM_CATTRIP);

  DUT_1 : entity work.aurora_user_interface_top
    generic map (
      EXAMPLE_SIMULATION => EXAMPLE_SIMULATION)
    port map (
      RESET          => RESET,
      GT_REFCLK1_N   => GT_REFCLK1_N,
      GT_REFCLK1_P   => GT_REFCLK1_P,
      RESETN         => RESETN,
      GTY_SYSCLKP_I  => GTY_SYSCLKP_I,
      GTY_SYSCLKN_I  => GTY_SYSCLKN_I,
      TXN            => TXN_1,
      TXP            => TXP_1,
      RXN            => RXN_1,
      RXP            => RXP_1,
      HBM_CATTRIP    => HBM_CATTRIP);


  -- clock generation
  process
  begin
    GTY_SYSCLKP_I <='0';
    GTY_SYSCLKN_I <='1';
    wait for Tclk_init/2;    
    GTY_SYSCLKP_I <='1';
    GTY_SYSCLKN_I <='0';
    wait for Tclk_init/2;

  end process;

  process
  begin
    GT_REFCLK1_P <= '0';
    GT_REFCLK1_N <= '1';
    wait for Tclk_gtRef/2;

    GT_REFCLK1_P <= '1';
    GT_REFCLK1_N <= '0';
    wait for Tclk_gtRef/2;

  end process;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    RESETN      <= '0';
    RESET       <= '1';
    wait until GTY_SYSCLKP_I'event and GTY_SYSCLKP_I = '1';
    RESETN      <= '1';    
    wait for 4*Tclk_init;
    wait until GTY_SYSCLKP_I'event and GTY_SYSCLKP_I = '1';
    RESET       <= '0';
    wait for 8000*Tclk_init;
    wait until GTY_SYSCLKP_I'event and GTY_SYSCLKP_I = '1';
    -- end simulation
    wait for 2*Tclk_init;
    assert false
      report "done"
      severity failure;
  end process WaveGen_Proc;


end architecture testbench;

