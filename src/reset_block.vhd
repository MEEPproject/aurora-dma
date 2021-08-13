-------------------------------------------------------------------------------
-- Title      : Reset block
-- Project    : MEEP
-------------------------------------------------------------------------------
-- File        : reset_block.vhd
-- Author      : Francelly K. Cano Ladino; francelly.canoladino@bsc.es
-- Company     : Barcelona Supercomputing Center (BSC)
-- Created     : 19/01/2021 - 19:12:35
-- Last update : Fri Feb 26 09:01:59 2021
-- Synthesizer : <Name> <version>
-- FPGA        : Alveo U280
-------------------------------------------------------------------------------
-- Description: This module will implement reset block to work with Auror 64B/66B core.
---- Constants: We need to define the minimum time to assert reset_pb with pma_init, for a normal sequence
--pma_init:________________--1s--__________________
--reset_pb:___----- 128clk-+-1s+--128clk---__________
--We are using a reference clock: 161.132812MHz. We want to achive 128�user_CLK=812.2ns.
-- With our reference clock period que have to wait: 132�init_clk=819.19ns
--Signals:
--   INIT_CLK: This signal is used to register and debounce the pma_init signal.
--   RESET: This signal is the push-button.
--   CHANNEL_UP: Asserted when The Aurora 64B/66B channel initialization is complete, and the channel is ready to send/receive data.
--   SYS_RESET: This signal is used to generate reset from Frame_gen and
--              Frame_check modules.
--   PMA_INIT: Systematically resets all (PCS) and (PMA).
--   RESET_PB: This signal reset the logic of the core.
--   RESET_FG: This is the reset for Frame generator module.
--   RESET_FC: This is the reset for Frame checker module.
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

entity reset_block is
 generic (
    INITCLOCK_FREQ_MHZ : integer := 200
    );
  port (
-- Inputs
    INIT_CLK   : in std_logic;
    RESET      : in std_logic;  --VIO reset preferences pma_init, reset_pb
    CHANNEL_UP : in std_logic;
    SYS_RESET  : in std_logic;

--  Outputs
    PMA_INIT : out std_logic;
    RESET_PB : out std_logic;
    RESET_UI : out std_logic
    

    );

end entity reset_block;

architecture rtl of reset_block is
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

  constant CLKHIGH_MINIMUM : natural := 132;
  constant ONE_SECOND      : natural := INITCLOCK_FREQ_MHZ*1000000;--161;--161132812;
  constant TOTAL_COUNTER   : natural := ONE_SECOND + CLKHIGH_MINIMUM;--187;--161133076;

--------------------------------------------------------------------------------
-- signal: We need an internal counter signal
--------------------------------------------------------------------------------

  signal counter_reset : std_logic_vector(27 downto 0);  
  signal ena_reset     : std_logic;  
  type t_status is (reset_i, count_i); 
  signal status        : t_status;
 
begin

--------------------------------------------------------------------------------
-- Generate pma_init, reset_pb
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Counter
-------------------------------------------------------------------------------
  process(INIT_CLK)
  begin
    if rising_edge(INIT_CLK) then
      if RESET = '1' then
        counter_reset <= (others => '0');
      elsif counter_reset = TOTAL_COUNTER then
        counter_reset <= (others => '0');

      else
        counter_reset <= counter_reset + 1;


      end if;
    end if;
  end process;

--FSM
  process(INIT_CLK)
  begin
    if rising_edge(INIT_CLK) then
      case status is
        when reset_i =>
          if RESET = '1' then
            ena_reset <= '1';
            status    <= count_i;
          else
            ena_reset <= '0';
          end if;
        when count_i =>
          if counter_reset = TOTAL_COUNTER then
            ena_reset <= '0';
            status    <= reset_i;
          end if;
      end case;
    end if;
  end process;
  


-------------------------------------------------------------------------------
-- Generate PMA_INIT, RESET_PB
-------------------------------------------------------------------------------

  PMA_INIT <= '1' when counter_reset >= CLKHIGH_MINIMUM and counter_reset <= ONE_SECOND and ena_reset = '1' else
              '0';

  RESET_PB <= '1' when counter_reset >= 0 and counter_reset <= (TOTAL_COUNTER) and ena_reset = '1' else
              '0';

--------------------------------------------------------------------------------
-- Generate RESET_UI
--------------------------------------------------------------------------------

  RESET_UI <=  SYS_RESET or not CHANNEL_UP;

  

end architecture rtl;
