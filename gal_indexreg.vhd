----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:05:53 02/27/2017 
-- Design Name: 
-- Module Name:    gal_indexreg - Behavioral 
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

use work.tinycpu_common.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gal_indexreg is
    Port ( reset : in  STD_LOGIC;
			  clock : in  STD_LOGIC;
			  sel : in STD_LOGIC;
           macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  data: in STD_LOGIC_VECTOR(3 downto 0);
           index : out  STD_LOGIC_VECTOR (3 downto 0);
           isZero : out  STD_LOGIC);
end gal_indexreg;

architecture Behavioral of gal_indexreg is

alias opcode: 		std_logic_vector(3 downto 0) is macro_i(7 downto 4);
alias regaddress:	std_logic is macro_i(3);
alias operation: 	std_logic_vector(2 downto 0) is macro_i(2 downto 0);

signal index_val: unsigned(3 downto 0);
signal enable: std_logic;

begin

	enable <= '1' when (opcode = std_logic_vector(opcode_IRO) and sel = regaddress) else '0';
	isZero <= '1' when index_val = 0 else '0';
	index <= std_logic_vector(index_val);
	
update: process(reset, clock, enable)
begin
	if (reset = '1') then
		index_val <= x"0";
	else
		if (rising_edge(clock)) then
			if (enable = '1') then
				case operation is
					when "000" =>
						index_val <= x"0";
					when "001" =>
						index_val <= index_val + 1;
					when "010" =>
						index_val <= index_val - 1;
					when "011" =>
						index_val <= unsigned(data);
					when "100" =>
						index_val <= x"C";
					when "101" =>
						index_val <= x"D";
					when "110" =>
						index_val <= x"E";
					when "111" =>
						index_val <= x"F";
					when others =>
						null;
				end case;
			end if;
		end if;
	end if;
end process;

end Behavioral;

