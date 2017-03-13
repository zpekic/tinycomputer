----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    23:44:29 03/08/2016 
-- Design Name: 
-- Module Name:    PmodKYPD - Behavioral (http://store.digilentinc.com/pmodkypd-16-button-keypad/)
-- Project Name:   Alarm Clock
-- Target Devices: Mercury FPGA + Baseboard (http://www.micro-nova.com/mercury/)
-- Tool versions:  Xilinx ISE 14.7 (nt64)
-- Description:    12hr/24hr alarm clock with display dimming showcasing baseboard hardware
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

entity PmodKYPD is
    Port ( 
           clk : in  STD_LOGIC;
			  reset: in STD_LOGIC;
			  bcdmode: in STD_LOGIC;
           Col : out  STD_LOGIC_VECTOR (3 downto 0);
			  Row : in  STD_LOGIC_VECTOR (3 downto 0);
           entry : out  STD_LOGIC_VECTOR (15 downto 0);
			  key_code: out  STD_LOGIC_VECTOR (3 downto 0);
			  key_down: out STD_LOGIC
         );
end PmodKYPD;

use work.debouncer;

architecture Behavioral of PmodKYPD is

component debouncer is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           signal_in : in  STD_LOGIC;
           signal_out : out  STD_LOGIC);
end component;

signal counter: unsigned(3 downto 0);

signal entry_internal: STD_LOGIC_VECTOR (15 downto 0);
signal key_code_internal: STD_LOGIC_VECTOR (3 downto 0);
signal key_down_internal: STD_LOGIC;

signal key_pressed: STD_LOGIC; 
signal matrix: STD_LOGIC_VECTOR(7 downto 0);

begin
-- these will be consumed internally, and connected to outputs too
entry <= entry_internal;
key_code <= key_code_internal;
key_down <= key_down_internal;
-- scan columns by decode to '0' (because rows have pull-ups)
Col(3 downto 0) <= matrix(7 downto 4);

key_pressed <= (matrix(3) and (not row(3))) or 
					(matrix(2) and (not row(2))) or 
					(matrix(1) and (not row(1))) or 
					(matrix(0) and (not row(0)));

-- scanning rows and cols
scan_key: process(reset, bcdmode, clk)
begin
   if (reset = '1') then
		counter <= "0000";
	else
		if (clk'event and clk = '1') then
			if (bcdmode = '1' and counter = "1001") then
				counter <= "0000";
			else
				counter <= counter + 1;
			end if;
		end if;
	   if (clk'event and clk = '0') then
			key_down_internal <= key_pressed;-- and not key_mask;
			key_code_internal <= std_logic_vector(counter); --key_value;	
		end if;
	end if;
end process;

map_key: process(clk, counter)
begin
	if (clk = '1') then
			case counter is
				when X"0" =>
					matrix <= "11101000";
				when X"1" =>
					matrix <= "11100001";
				when X"2" =>
					matrix <= "11010001";
				when X"3" =>
					matrix <= "10110001";
				when X"4" =>
					matrix <= "11100010";
				when X"5" =>
					matrix <= "11010010";
				when X"6" =>
					matrix <= "10110010";
				when X"7" =>
					matrix <= "11100100";
				when X"8" =>
					matrix <= "11010100";
				when X"9" =>
					matrix <= "10110100";
				when X"A" =>
					matrix <= "01110001";
				when X"B" =>
					matrix <= "01110010";
				when X"C" =>
					matrix <= "01110100";
				when X"D" =>
					matrix <= "01111000";
				when X"E" =>
					matrix <= "10111000";
				when X"F" =>
					matrix <= "11011000";
				when others =>
					null;
			end case;
		end if;
end process;

-- react to key
capture_key: process(reset, key_down_internal)
begin
   if (reset = '1') then
		entry_internal <= X"0000";
	else
		if (key_down_internal'event and key_down_internal = '1') then
				entry_internal(15 downto 0) <= entry_internal(11 downto 0) & key_code_internal;
		end if;
	end if;
end process;

end Behavioral;

