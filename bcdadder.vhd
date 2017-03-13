----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:52:18 11/16/2016 
-- Design Name: 
-- Module Name:    bcdadder - Behavioral 
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

entity bcdadder is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           cin : in  STD_LOGIC;
           sum : out  STD_LOGIC_VECTOR (3 downto 0);
           cout : out  STD_LOGIC);
end bcdadder;

architecture Behavioral of bcdadder is

signal raw_sum, adjusted_sum: std_logic_vector(5 downto 0);

begin

raw_sum <= std_logic_vector(unsigned('0' & a & cin) + unsigned('0' & b & cin));
adjusted_sum <= raw_sum when (raw_sum < "010100") else std_logic_vector(unsigned(raw_sum) + "001100");

sum <= adjusted_sum(4 downto 1);
cout <= adjusted_sum(5);

end Behavioral;

