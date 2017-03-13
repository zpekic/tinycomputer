----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    15:42:44 02/20/2016 
-- Design Name: 
-- Module Name:    fourdigitsevensegled - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fourdigitsevensegled is
    Port ( -- inputs
			  data : in  STD_LOGIC_VECTOR (15 downto 0);
           digsel : in  STD_LOGIC_VECTOR (1 downto 0);
           showdigit : in  STD_LOGIC_VECTOR (3 downto 0);
           showdot : in  STD_LOGIC_VECTOR (3 downto 0);
           showsegments : in  STD_LOGIC;
			  -- outputs
           anode : out  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end fourdigitsevensegled;

architecture structural of fourdigitsevensegled is

component nibble2sevenseg is
    Port ( nibble : in  STD_LOGIC_VECTOR (3 downto 0);
           segment : out  STD_LOGIC_VECTOR (6 downto 0)
			);
end component;

component mux16to4
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           c : in  STD_LOGIC_VECTOR (3 downto 0);
           d : in  STD_LOGIC_VECTOR (3 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0);
			  nEnable : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (3 downto 0)
			 );
end component;

signal internalsegment: std_logic_vector(7 downto 0); -- 7th is the dot!
signal internalsel: std_logic_vector(3 downto 0);
signal digit: std_logic_vector(3 downto 0);

begin
-- decode position
   internalsel(3) <= digsel(1) and digsel(0);
   internalsel(2) <= digsel(1) and (not digsel(0));
   internalsel(1) <= (not digsel(1)) and digsel(0);
   internalsel(0) <= (not digsel(1)) and (not digsel(0));
-- select 1 digit out of 4 incoming	
   digitmux: mux16to4 port map (
								a => data(3 downto 0), 
								b => data(7 downto 4),  
								c => data(11 downto 8),  
								d => data(15 downto 12), 
								nEnable => '0',
								sel => digsel,
								y => digit
									);
-- set the anodes with digit blanking
	anode(3) <= not (internalsel(3) and showdigit(3));
	anode(2) <= not (internalsel(2) and showdigit(2));
	anode(1) <= not (internalsel(1) and showdigit(1));
	anode(0) <= not (internalsel(0) and showdigit(0));
-- hook up the cathodes
   sevensegdriver: nibble2sevenseg port map (
								nibble => digit,
								segment => internalsegment(6 downto 0)
									);
-- set cathodes with blanking (seg7 == dot)
	segment(7) <= (not showsegments) or ((internalsel(3) and not showdot(3)) or (internalsel(2) and not showdot(2)) or (internalsel(1) and not showdot(1)) or (internalsel(0) and not showdot(0)));
	segs: for i in 6 downto 0 generate
		segment(i) <= (not showsegments) or internalsegment(i);
	end generate;	

end structural;

