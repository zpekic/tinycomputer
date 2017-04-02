----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:09:18 03/19/2017 
-- Design Name: 
-- Module Name:    gal_glue - Behavioral 
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

entity gal_glue is
    Port ( 
			  reset: in STD_LOGIC;
			  clock: in STD_LOGIC;
			  i : in  STD_LOGIC_VECTOR (7 downto 0);
			  nRead: in STD_LOGIC;
			  nWrite: in STD_LOGIC;
			  nIo_Read: out STD_LOGIC;
			  nIo_Write: out STD_LOGIC;
           carry_in : in  STD_LOGIC;
           carry_out : out  STD_LOGIC;
			  execute: in STD_LOGIC;
			  ss_mode: in STD_LOGIC;
			  step: in STD_LOGIC;
			  ss_clock: out STD_LOGIC);
end gal_glue;

architecture Behavioral of gal_glue is

alias operation: std_logic_vector(3 downto 0) is i(7 downto 4);
signal opcode: unsigned (3 downto 0);
signal enable_clock: std_logic;

begin

ss_clock <= clock and enable_clock;
 
opcode <= unsigned(operation);
nIo_Read <= nRead;
nIo_write <= nWrite or clock;

eval_ss: process(clock, reset)
begin
	if (reset = '1') then
		enable_clock <= '1';
	else
		if (falling_edge(clock) and execute = '1') then
			if (enable_clock = '1') then
				enable_clock <= not ss_mode;
			else 
				enable_clock <= step;
			end if;
		end if;
	end if;
end process;

mux_c: process(i, carry_in)
begin
	case opcode is
		when opcode_CPQ =>
			carry_out <= '1'; -- compare is a substract, so set to 1
		when opcode_ADQ =>
			carry_out <= '0'; -- add quick is an add so set to 0
		when others =>
			carry_out <= carry_in; -- flag pass-through
	end case;
end process;

end Behavioral;

