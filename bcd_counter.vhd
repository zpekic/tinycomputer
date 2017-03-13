----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:45:57 11/07/2016 
-- Design Name: 
-- Module Name:    bcd_counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

entity bcd_counter is
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
end bcd_counter;

architecture Behavioral of bcd_counter is

signal is_zero_internal, is_maxval_internal: std_logic;
signal inc_val, dec_val: std_logic_vector(7 downto 0);
signal counter: std_logic_vector(7 downto 0);
signal mode: std_logic_vector(2 downto 0);

begin

-- outputs
is_zero <= is_zero_internal;
is_maxval <= is_maxval_internal;
bcd <= counter;

-- internal signals
is_zero_internal <= '1' when counter = X"00" else '0';
is_maxval_internal <= '1' when counter = maxval else '0';
mode(2 downto 0) <= set & inc & dec;

inc_val <= X"01" when counter(3 downto 0) /= X"9" else X"07"; -- 0x08 + 0x01 = 0x09 + 0x07 = 0x10
dec_val <= X"FF" when counter(3 downto 0) /= X"0" else X"F9"; -- 0x21 + 0xFF = 0x20 + 0xf9 = 0x19 

update: process (reset, clk, mode, is_zero_internal, is_maxval_internal)
begin
 if (reset = '1') then
	counter <= X"00";
 else
	if (rising_edge(clk)) then
		case (mode) is
			when "100" => -- ingest single bcd digit
				counter(7 downto 0) <= counter(3 downto 0) & setval;
			when "010" => -- increment
				if (is_maxval_internal = '1') then
					counter <= X"00";
				else 
					counter <= std_logic_vector(unsigned(counter) + unsigned(inc_val));
				end if;
			when "001" => -- decrement
				if (is_zero_internal = '1') then
					counter <= maxval;
				else
					counter <= std_logic_vector(unsigned(counter) + unsigned(dec_val));
				end if;
			when "011" => -- synchronous reset
				counter <= X"00"; 
			when others =>
				null;
		end case;
	end if;
 end if;
 
end process;
 
end Behavioral;

