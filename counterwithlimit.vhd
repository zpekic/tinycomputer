----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    11:26:14 02/14/2016 
-- Design Name: 
-- Module Name:    counterwithlimit - Behavioral 
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

entity counterwithlimit is
    Port ( clock : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
			  set : in STD_LOGIC;
			  set_value : in STD_LOGIC_VECTOR(3 downto 0);
           limit : in  STD_LOGIC_VECTOR (3 downto 0);
			  
           out_count : out  STD_LOGIC_VECTOR (3 downto 0);
           out_zero : out  STD_LOGIC;
           out_limit : out  STD_LOGIC);
end counterwithlimit;

architecture Behavioral of counterwithlimit is

	signal cnt: unsigned(3 downto 0);

begin
	out_count <= std_logic_vector(cnt);	
	out_zero <= '1' when cnt = X"0" else '0';
	out_limit <= '1' when cnt = unsigned(limit) else '0';
	
	count: process(clock, clear, set, up, down)
	begin
		if clear = '1' then
			cnt <= "0000";
		else
			if (clock'event and clock = '1') then
				if (set = '1') then
					cnt <= unsigned(set_value); -- setting to a value keyed in
				else
					if up = '1' then
						if cnt >= unsigned(limit) then
							cnt <= "0000";
						else
							cnt <= cnt + 1;
						end if;
					end if;
					if down = '1' then
						if cnt = "0000" then
							cnt <= unsigned(limit);
						else 
							cnt <= cnt - 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

