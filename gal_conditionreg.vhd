----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:32:24 03/14/2017 
-- Design Name: 
-- Module Name:    gal_conditionreg - Behavioral 
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

use work.tinycpu_common.all;

entity gal_conditionreg is
    Port ( clock : in  STD_LOGIC;
			  execute : in STD_LOGIC;
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           alu_c : in  STD_LOGIC;
           alu_z : in  STD_LOGIC;
           alu_v : in  STD_LOGIC;
           alu_n : in  STD_LOGIC;
           alu_xleft : in  STD_LOGIC;
           alu_xright : in  STD_LOGIC;
           flags : buffer  STD_LOGIC_VECTOR (4 downto 0));
end gal_conditionreg;

architecture Behavioral of gal_conditionreg is

signal mask: std_logic_vector(7 downto 0);
-- interpretation of the instruction code
alias operation: std_logic_vector(3 downto 0) is i(7 downto 4);
signal opcode: unsigned (3 downto 0);
alias invertmask: std_logic is i(3);
alias bitselect:	std_logic_vector(2 downto 0) is i(2 downto 0);
-- flag bits
alias c: std_logic is flags(0);
alias z: std_logic is flags(1);
alias v: std_logic is flags(2);
alias n: std_logic is flags(3);
alias x: std_logic is flags(4);


begin

opcode <= unsigned(operation);
-- decode last 3 instruction bits to mask for set flag / reset flag operations
with bitselect select
	mask <= 	"00000001" when "000",
				"00000010" when "001",
				"00000100" when "010",
				"00001000" when "011",
				"00010000" when "100",
				"00100000" when "101",
				"01000000" when "110",
				"10000000" when "111",
				"00000000" when others;

update_flags: process(clock, execute) 
begin
	if (execute = '1') then
		if (rising_edge(clock)) then
			case opcode is
				when opcode_INP|opcode_LDQ|opcode_AND|opcode_IOR|opcode_XOR =>
					z <= alu_z;
					n <= alu_n;
				when opcode_CPQ|opcode_ADQ|opcode_ADC|opcode_SBC =>
					c <= alu_c;
					z <= alu_z;
					v <= alu_v;
					n <= alu_n;
				when opcode_FLG =>
					if (invertmask = '1') then
						c <= c and (not mask(0));
						z <= z and (not mask(1));
						v <= v and (not mask(2));
						n <= n and (not mask(3));
						x <= x and (not mask(4));
					else
						c <= c or mask(0);
						z <= z or mask(1);
						v <= v or mask(2);
						n <= n or mask(3);
						x <= x or mask(4);
					end if;
				when others =>
					null;
			end case;
		end if;
	end if;
end process;

end Behavioral;
