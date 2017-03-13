----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    16:56:54 02/13/2016 
-- Design Name: 
-- Module Name:    clock_divider - rtl 
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

entity clock_divider is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           div : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end clock_divider;

architecture rtl of clock_divider is
	constant max_count: integer := 195312; -- 50MHz to 256Hz (this is a bit bad because it is rounded down!)
	signal count: integer range 0 to max_count := 0; 
	signal cnt: unsigned(7 downto 0);
	
begin
		
	divider: process(clock, reset)
		begin
		if reset = '1' then
			count <= 0;
			cnt <= "00000000";
		else
			if clock'event and clock = '1' then
				if count = max_count then
					count <= 0;
					cnt <= cnt + 1;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
   -- connect divider output with internal counter
	div <= std_logic_vector(cnt);
end rtl;

