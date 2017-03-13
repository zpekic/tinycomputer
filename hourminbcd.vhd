----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    20:49:24 02/20/2016 
-- Design Name: 
-- Module Name:    hourminbcd - structural 
-- Project Name:   Alarm Clock
-- Target Devices: Mercury FPGA + Baseboard (http://www.micro-nova.com/mercury/)
-- Tool versions:  Xilinx ISE 14.7 (nt64)
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hourminbcd is
    Port ( reset : in  STD_LOGIC;
           sync : in  STD_LOGIC;
			  pulse: in STD_LOGIC;
			  
           set_hr : in  STD_LOGIC;
           set_min : in  STD_LOGIC;
			  set_inc : in STD_LOGIC;
           set_dec : in  STD_LOGIC;
			  key_code : in STD_LOGIC_VECTOR(3 downto 0);
			  key_hit : in STD_LOGIC;
			  
           bcdout : out  STD_LOGIC_VECTOR (15 downto 0);
			  
			  debug: out STD_LOGIC_VECTOR(3 downto 0)
			);
end hourminbcd;

use work.counterwithlimit;

architecture structural of hourminbcd is

component bcd_counter is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           set : in  STD_LOGIC;
           inc : in  STD_LOGIC;
           dec : in  STD_LOGIC;
           maxval : in  STD_LOGIC_VECTOR (7 downto 0);
			  setval : in  STD_LOGIC_VECTOR (3 downto 0);
           is_zero : out  STD_LOGIC;
           is_maxval : out  STD_LOGIC;
           bcd : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal sync_min, inc_min, dec_min, maxval_min, zero_min: std_logic;
signal sync_hr, inc_hr, dec_hr: std_logic;
signal min_key, min_up, min_down: std_logic;
signal hour_key, hour_up, hour_down: std_logic;

begin

condition_signals: process(sync) 
begin
	if (falling_edge(sync)) then
		-- filter out defined button combinations for setting minutes
		min_key <= (not set_hr) and set_min and (not set_inc) and (not set_dec);
		min_up <= (not set_hr) and set_min and set_inc and (not set_dec);
		min_down <= (not set_hr) and set_min and (not set_inc) and set_dec;
		-- filter out defined button combinations for setting minutes
		hour_key <= set_hr and (not set_min) and (not set_inc) and (not set_dec);
		hour_up <= set_hr and (not set_min) and set_inc and (not set_dec);
		hour_down <= set_hr and (not set_min) and (not set_inc) and set_dec;
	end if;
end process;

-- drive minute digits
sync_min <= (min_key and key_hit) or ((not min_key) and sync);
inc_min <= min_up or ((not min_up) and pulse);
dec_min <= min_down;
-- drive hour digits
sync_hr  <= (hour_key and key_hit) or ((not hour_key) and sync);
inc_hr <= hour_up or ((not hour_up) and maxval_min and pulse);
dec_hr <= hour_down;

-- debug signals
debug(3) <= inc_min;
debug(2) <= dec_min;
debug(1) <= sync_min;
debug(0) <= sync;

min: bcd_counter port map (
			  reset => reset,
           clk => sync_min,
           set => min_key,
           inc => inc_min,
           dec => dec_min,
           maxval => X"59",
			  setval => key_code,
           is_zero => zero_min,
           is_maxval => maxval_min,
           bcd => bcdout(7 downto 0)
);

hour: bcd_counter port map (
			  reset => reset,
           clk => sync_hr,
           set => hour_key,
           inc => inc_hr,
           dec => dec_hr,
           maxval => X"23",
			  setval => key_code,
           --is_zero => debug(2),
           --is_maxval => debug(3),
           bcd => bcdout(15 downto 8)
);

	
end structural;

