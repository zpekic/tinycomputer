----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    21:07:52 02/22/2016 
-- Design Name: 
-- Module Name:    converter24to12 - Behavioral 
-- Project Name:   Alarm Clock
-- Target Devices: Mercury FPGA + Baseboard (http://www.micro-nova.com/mercury/)
-- Tool versions:  Xilinx ISE 14.7 (nt64)-- Company: 

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

entity converter24to12 is
    Port ( select_12hr : in  STD_LOGIC;
           hour24 : in  STD_LOGIC_VECTOR (7 downto 0);
			  
           hour_ispm : out  STD_LOGIC;
           hour_12or24 : out  STD_LOGIC_VECTOR (7 downto 0));
end converter24to12;

architecture Behavioral of converter24to12 is

begin
	convert: process(select_12hr, hour24)
	begin
		if (select_12hr = '1') then
			-- convert to 12hr mode (note both input and outputs are BCD!)
			case hour24 is
				when "00000000" => -- 00 is 12am
					hour_12or24 <= "00010010";
					hour_ispm <= '0';
				when "00000001" => -- 01 is 01am
					hour_12or24 <= "00000001";
					hour_ispm <= '0';
				when "00000010" => -- 02 is 02am
					hour_12or24 <= "00000010";
					hour_ispm <= '0';
				when "00000011" => -- 03 is 03am
					hour_12or24 <= "00000011";
					hour_ispm <= '0';
				when "00000100" => -- 04 is 04am
					hour_12or24 <= "00000100";
					hour_ispm <= '0';
				when "00000101" => -- 05 is 05am
					hour_12or24 <= "00000101";
					hour_ispm <= '0';
				when "00000110" => -- 06 is 06am
					hour_12or24 <= "00000110";
					hour_ispm <= '0';
				when "00000111" => -- 07 is 07am
					hour_12or24 <= "00000111";
					hour_ispm <= '0';
				when "00001000" => -- 08 is 08am
					hour_12or24 <= "00001000";
					hour_ispm <= '0';
				when "00001001" => -- 09 is 09am
					hour_12or24 <= "00001001";
					hour_ispm <= '0';
				when "00010000" => -- 10 is 10am
					hour_12or24 <= "00010000";
					hour_ispm <= '0';
				when "00010001" => -- 11 is 11am
					hour_12or24 <= "00010001";
					hour_ispm <= '0';
				when "00010010" => -- 12 is 12pm
					hour_12or24 <= "00010010";
					hour_ispm <= '1';
				when "00010011" => -- 13 is 01pm
					hour_12or24 <= "00000001";
					hour_ispm <= '1';
				when "00010100" => -- 14 is 02pm
					hour_12or24 <= "00000010";
					hour_ispm <= '1';
				when "00010101" => -- 15 is 03pm
					hour_12or24 <= "00000011";
					hour_ispm <= '1';
				when "00010110" => -- 16 is 04pm
					hour_12or24 <= "00000100";
					hour_ispm <= '1';
				when "00010111" => -- 17 is 05pm
					hour_12or24 <= "00000101";
					hour_ispm <= '1';
				when "00011000" => -- 18 is 06pm
					hour_12or24 <= "00000110";
					hour_ispm <= '1';
				when "00011001" => -- 19 is 07pm
					hour_12or24 <= "00000111";
					hour_ispm <= '1';
				when "00100000" => -- 20 is 08pm
					hour_12or24 <= "00001000";
					hour_ispm <= '1';
				when "00100001" => -- 21 is 09pm
					hour_12or24 <= "00001001";
					hour_ispm <= '1';
				when "00100010" => -- 22 is 10pm
					hour_12or24 <= "00010000";
					hour_ispm <= '1';
				when "00100011" => -- 23 is 11pm
					hour_12or24 <= "00010001";
					hour_ispm <= '1';
				when others =>
					null;
			end case;
		else
			-- we are in 24hr mode, no change
			hour_12or24 <= hour24;
			hour_ispm <= '0';
		end if;
	end process;


end Behavioral;

