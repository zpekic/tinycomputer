----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:51:11 02/28/2017 
-- Design Name: 
-- Module Name:    gal_brancher - Behavioral 
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

use work.tinycpu_common.all;

entity gal_brancher is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           condition : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : buffer  STD_LOGIC;
           branch : buffer  STD_LOGIC;
			  callorreturn: buffer STD_LOGIC);
end gal_brancher;

architecture Behavioral of gal_brancher is

alias current_opcode: std_logic_vector(3 downto 0) is i(7 downto 4);
alias condition_invert: std_logic is i(3);
alias condition_select: std_logic_vector(2 downto 0) is i(2 downto 0);

signal condition_selected: std_logic;

begin

with condition_select select
	condition_selected <= 	condition(0) when "000",
									condition(1) when "001",
									condition(2) when "010",
									condition(3) when "011",
									condition(4) when "100",
									condition(5) when "101",
									condition(6) when "110",
									condition(7) when others;

capture: process (reset, clock, condition_selected, condition_invert)
begin
	if (reset = '1') then
		execute <= '1';
		branch <= '0';
		callorreturn <= '0';
	else
		if (rising_edge(clock)) then
				if (execute = '1') then
					if (current_opcode = std_logic_vector(opcode_BRA)) then
						-- next PC will be at offset, so don't interpret as instruction
						execute <= '0';
						-- capture the branch flag for next cycle
						branch <= condition_invert xor condition_selected;
						-- determine if next cycle will be call or return
						if (condition_select = "111") then
							callorreturn <= '1'; 
						else
							callorreturn <= '0'; 
						end if;
					else
						-- this was a regular 1 byte instruction, next PC will point to one too
						execute <= '1';
						-- these values will be ignored, but set to 0 for consistency
						branch <= '0';
						callorreturn <= '0';
					end if;
				else
					-- PC is pointing to branch offset, therefore next cycle should be executed
					execute <= '1';
					-- these values will be ignored, but set to 0 for consistency
					branch <= '0';
					callorreturn <= '0';
				end if;
		end if;
	end if;

end process;									
									

end Behavioral;

