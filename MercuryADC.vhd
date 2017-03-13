--     __  ____                 _   __                
--    /  |/  (_)_____________  / | / /___ _   ______ _
--   / /|_/ / / ___/ ___/ __ \/  |/ / __ \ | / / __ `/
--  / /  / / / /__/ /  / /_/ / /|  / /_/ / |/ / /_/ / 
-- /_/  /_/_/\___/_/   \____/_/ |_/\____/|___/\__,_/                
-------------------------------------------------------------------------------
-- Title      : Mercury ADC
-- Last update: 2014-11-10
-- Revision   : 1.0.139
-------------------------------------------------------------------------------
-- Copyright (c) 2013 MicroNova, LLC
-- www.micro-nova.com
-------------------------------------------------------------------------------
--
-- This module interfaces with Mercury's onboard MCP3008 ADC.
-- This is an 8-channel 10-bit ADC with an SPI interface.
--
-- To use this module:
-- 1. Drive "diffn" with '1' for single-ended or '0' for 
--    differential input mode.
-- 2. Drive "channel" with the desired ADC channel number.
-- 3. Pulse "trigger" for a single cycle.
-- 4. After ADC has been sampled, this module will pulse "OutVal".
-- 5. "Dout" contains the 10-bit ADC value.
--
-- NOTE: Take care that you do not exceed the maximum sample rate of the ADC.
--       This is 200-ksps for a Vref of 5V and 100-ksps for a Vref of 3.3V,
--       which correspond to clock of 3.6MHz and 1.8MHz respectively.
--       See Microchip's datasheet for more details:
--       http://ww1.microchip.com/downloads/en/DeviceDoc/21295d.pdf
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MercuryADC is
  port
    (
      -- command input
      clock    : in  std_logic;         -- 50MHz onboard oscillator
      trigger  : in  std_logic;         -- assert to sample ADC
      diffn    : in  std_logic;         -- single/differential inputs
      channel  : in  std_logic_vector(2 downto 0);  -- channel to sample
      -- data output
      Dout     : out std_logic_vector(9 downto 0);  -- data from ADC
      OutVal   : out std_logic;         -- pulsed when data sampled
      -- ADC connection
      adc_miso : in  std_logic;         -- ADC SPI MISO
      adc_mosi : out std_logic;         -- ADC SPI MOSI
      adc_cs   : out std_logic;         -- ADC SPI CHIP SELECT
      adc_clk  : out std_logic          -- ADC SPI CLOCK
      );

end MercuryADC;

architecture rtl of MercuryADC is

  -- clock
  signal adc_clock : std_logic := '0';

  -- command
  signal trigger_flag : std_logic                    := '0';
  signal sgl_diff_reg : std_logic;
  signal channel_reg  : std_logic_vector(2 downto 0) := (others => '0');
  signal done         : std_logic                    := '0';
  signal done_prev    : std_logic                    := '0';

  -- output registers
  signal val : std_logic                    := '0';
  signal D   : std_logic_vector(9 downto 0) := (others => '0');

  -- state control
  signal state     : std_logic                    := '0';
  signal spi_count : unsigned(4 downto 0)         := (others => '0');
  signal Q         : std_logic_vector(9 downto 0) := (others => '0');
  
begin

  -- clock divider
  -- input clock: 50MHz
  -- adc clock: ~3.57MHz (198.4-ksps)
  clock_divider : process(clock)
  variable cnt : integer := 0;
  begin
    if rising_edge(clock) then
      cnt := cnt + 1;
      if cnt = 7 then
        cnt := 0;
        adc_clock <= not adc_clock;
      end if;
    end if;
  end process;

  -- produce trigger flag
  trigger_cdc : process(clock)
  begin
    if rising_edge(clock) then
      if trigger = '1' and state = '0' then
        sgl_diff_reg <= diffn;
        channel_reg  <= channel;
        trigger_flag <= '1';
      elsif state = '1' then
        trigger_flag <= '0';
      end if;
    end if;
  end process;

  adc_clk <= adc_clock;
  adc_cs  <= not state;

  -- SPI state machine (falling edge)
  adc_sm : process(adc_clock)
  begin
    if adc_clock'event and adc_clock = '0' then
      if state = '0' then
        done <= '0';
        if trigger_flag = '1' then
          state <= '1';
        else
          state <= '0';
        end if;
      else
        if spi_count = "10000" then
          spi_count <= (others => '0');
          state     <= '0';
          done      <= '1';
        else
          spi_count <= spi_count + 1;
          state     <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Register sample into 50MHz clock domain
  outreg : process(clock)
  begin
    if rising_edge(clock) then
      done_prev <= done;
      if done_prev = '0' and done = '1' then
        D   <= Q;
        Val <= '1';
      else
        Val <= '0';
      end if;
    end if;
  end process;

  Dout   <= D;
  OutVal <= Val;

  -- MISO shift register (rising edge)
  shift_in : process(adc_clock)
  begin
    if adc_clock'event and adc_clock = '1' then
      if state = '1' then
        Q(0)          <= adc_miso;
        Q(9 downto 1) <= Q(8 downto 0);
      end if;
    end if;
  end process;

  -- Decode MOSI output
  shift_out : process(state, spi_count, sgl_diff_reg, channel_reg)
  begin
    if state = '1' then
      case spi_count is
        when "00000" => adc_mosi <= '1';  -- start bit
        when "00001" => adc_mosi <= sgl_diff_reg;
        when "00010" => adc_mosi <= channel_reg(2);
        when "00011" => adc_mosi <= channel_reg(1);
        when "00100" => adc_mosi <= channel_reg(0);
        when others  => adc_mosi <= '0';
      end case;
    else
      adc_mosi <= '0';
    end if;
  end process;

end rtl;
