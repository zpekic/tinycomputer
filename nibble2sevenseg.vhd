----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:04:38 02/13/2016 
-- Design Name: 
-- Module Name:    nibble2sevenseg - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nibble2sevenseg is
    Port ( nibble : in  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (6 downto 0));
end nibble2sevenseg;

architecture Behavioral of nibble2sevenseg is

begin
	decode: process(nibble)
	begin
	case nibble is
		when "0000" =>
			segment <= "0000001"; -- 0
		when "0001" =>
			segment <= "1001111"; -- 1
		when "0010" =>
			segment <= "0010010"; -- 2
		when "0011" =>
			segment <= "0000110"; -- 3
		when "0100" =>
			segment <= "1001100"; -- 4
		when "0101" =>
			segment <= "0100100"; -- 5
		when "0110" =>
			segment <= "0100000"; -- 6
		when "0111" =>
			segment <= "0001111"; -- 7
		when "1000" =>
			segment <= "0000000"; -- 8
		when "1001" =>
			segment <= "0000100"; -- 9
		when "1010" =>
			segment <= "0001000"; -- A
		when "1011" =>
			segment <= "1100000"; -- b
		when "1100" =>
			segment <= "0110001"; -- C
		when "1101" =>
			segment <= "1000010"; -- d
		when "1110" =>
			segment <= "0110000"; -- E
		when "1111" =>
			segment <= "0111000"; -- F
		when others =>
		null;
	end case;
	end process;
end Behavioral;

