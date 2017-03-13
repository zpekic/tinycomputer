----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:21:30 03/04/2017 
-- Design Name: 
-- Module Name:    gal_progcounter - Behavioral 
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

entity gal_progcounter is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : in  STD_LOGIC;
           branch : in  STD_LOGIC;
           pc : buffer  STD_LOGIC_VECTOR (9 downto 0));
end gal_progcounter;

architecture Behavioral of gal_progcounter is

signal branchoffset: std_logic_vector(9 downto 0);

begin

branchoffset <= "00" & macro_i when (macro_i(7) = '0') else "11" & macro_i;

update_pc: process(reset, clock, execute, branch)
begin
	if (reset = '1') then
		pc <= "0000000000";
	else
		if (rising_edge(clock)) then
			if (branch = '1' and execute = '0') then
				pc <= std_logic_vector(unsigned(pc) + unsigned(branchoffset));
			else
				pc <= std_logic_vector(unsigned(pc) + 1);
			end if;
		end if;
	end if;
end process;

end Behavioral;

