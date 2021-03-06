----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:51:31 02/25/2017 
-- Design Name: 
-- Module Name:    gal_datamux - Behavioral 
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

entity gal_datamux is
    Port ( i : in  STD_LOGIC_VECTOR (7 downto 0);
           data_in : in  STD_LOGIC_VECTOR (3 downto 0);
           data_out : out  STD_LOGIC_VECTOR (3 downto 0);
           nRead : out  STD_LOGIC;
           nWrite : out  STD_LOGIC);
end gal_datamux;

architecture Behavioral of gal_datamux is

alias current_opcode: std_logic_vector(3 downto 0) is i(7 downto 4);
alias current_immediate: std_logic_vector(3 downto 0) is i(3 downto 0);

begin

	nRead <= '0' when (current_opcode = std_logic_vector(opcode_INP)) else '1';
	nWrite <= '0' when (current_opcode = std_logic_vector(opcode_OUT)) else '1';
	data_out <= data_in when (current_opcode = std_logic_vector(opcode_INP)) else current_immediate;

end Behavioral;

