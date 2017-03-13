----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    22:45:30 02/20/2016 
-- Design Name: 
-- Module Name:    comparatorwithstate - Behavioral 
-- Project Name:   Alarm Clock
-- Target Devices: Mercury FPGA + Baseboard (http://www.micro-nova.com/mercury/)
-- Tool versions:  Xilinx ISE 14.7 (nt64)
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

entity comparatorwithstate is
    Port ( a : in  STD_LOGIC_VECTOR (23 downto 0);
           b : in  STD_LOGIC_VECTOR (23 downto 0);
			  clock: in STD_LOGIC;
           reset : in  STD_LOGIC;
			  enable: in STD_LOGIC;
           trigger : out  STD_LOGIC);
end comparatorwithstate;

architecture rtl of comparatorwithstate is
	signal diff: std_logic_vector(23 downto 0);
	signal a_equals_b: boolean := false;

begin
 
 diff <= a xor b;
 
 settrigger: process(a_equals_b) 
 begin
	if (a_equals_b) then
		trigger <= '1';
	else
		trigger <= '0';
	end if;
 end process;
 
 setequals: process (clock, reset, enable, diff)
 begin
	if (reset = '1') then
		a_equals_b <= false;
	else
	   if (clock'event and clock = '1') then
			if (enable = '1' and not a_equals_b) then
				if (diff = "000000000000000000000000") then
					a_equals_b <= true;
				else
					a_equals_b <= false;
				end if;
			end if;
		end if;
	end if;
 end process;
 
end rtl;

