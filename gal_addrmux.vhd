----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:01:29 03/21/2017 
-- Design Name: 
-- Module Name:    gal_addrmux - Behavioral 
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

entity gal_addrmux is
    Port ( i : in  STD_LOGIC_VECTOR (7 downto 0);
           addrA : in  STD_LOGIC_VECTOR (3 downto 0);
           addrB : in  STD_LOGIC_VECTOR (3 downto 0);
           addr_bus : out  STD_LOGIC_VECTOR (3 downto 0));
end gal_addrmux;

architecture Behavioral of gal_addrmux is

alias op_value: std_logic_vector(3 downto 0) is i(3 downto 0);

begin

		with op_value select
		addr_bus <=		addrA when "1110", -- 14 is indirect, coming from A index reg
							addrB when "1111", -- 15 is indirect, coming from B index reg
							op_value when others; -- values 0 .. 13 mean direct address of channel or register

end Behavioral;

