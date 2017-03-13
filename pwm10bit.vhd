----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    01:57:47 02/27/2016 
-- Design Name: 
-- Module Name:    pwm10bit - Behavioral 
-- Project Name:   Alarm Clock
-- Target Devices: Mercury FPGA + Baseboard (http://www.micro-nova.com/mercury/)
-- Tool versions:  Xilinx ISE 14.7 (nt64)
--
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm10bit is
    Port ( clk : in  STD_LOGIC;
			  adc_samplingrate: in STD_LOGIC;	
           adc_channel : in  STD_LOGIC_VECTOR (2 downto 0);
			  adc_miso : in  std_logic;         -- ADC SPI MISO
			  adc_mosi : out std_logic;         -- ADC SPI MOSI
			  adc_cs   : out std_logic;         -- ADC SPI CHIP SELECT
			  adc_clk  : out std_logic;          -- ADC SPI CLOCK
			  adc_value: out std_logic_vector(15 downto 0);
			  adc_valid: out std_logic;
           pwm_out : out  STD_LOGIC);
end pwm10bit;

-- From http://www.micro-nova.com/resources/
use work.MercuryADC;

architecture Behavioral of pwm10bit is

component MercuryADC is
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
end component;

signal threshold: integer range 0 to 1023 := 0;
signal counter: integer range 0 to 1023 := 0;
signal adc_out: std_logic_vector(9 downto 0);
signal adc_pulse: std_logic;

begin

	-- map to output and extend to 16 bits
	adc_value <= "000000" & adc_out;
	adc_valid <= adc_pulse;
	
	adc: MercuryADC port map
			(
				-- command input
				clock    => clk,         		-- from onboard oscillator
				trigger  => adc_samplingrate, -- assert to sample ADC
				diffn    => '1',         		-- single/differential inputs
				channel  => adc_channel,  		-- channel to sample (3 == light sensor)
				-- data output
				Dout     => adc_out,  			-- data from ADC
				OutVal   => adc_pulse,        -- pulsed when data sampled
				-- ADC connection
				adc_miso => adc_miso,         -- ADC SPI MISO
				adc_mosi => adc_mosi,         -- ADC SPI MOSI
				adc_cs   => adc_cs,         	-- ADC SPI CHIP SELECT
				adc_clk  => adc_clk         	-- ADC SPI CLOCK
			);
			
	get_adc: process(adc_pulse)
		begin
			if (adc_pulse = '1') then
				threshold <= to_integer(unsigned(adc_out));
			end if;
		end process;
		
	generate_pwm: process(clk)
		begin
			if (clk'event and clk = '1') then
				counter <= counter + 1; -- just let it wrap around
				if (counter > threshold) then
					pwm_out <= '0';
				else
					pwm_out <= '1';
				end if;
			end if;
		end process;
	
end Behavioral;

