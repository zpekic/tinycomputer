----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:49:24 02/26/2017 
-- Design Name: 
-- Module Name:    gal_instrmapper - Behavioral 
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

use work.tinycpu_common.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gal_instrmapper is
    Port ( macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : in  STD_LOGIC;
           micro_i : out  STD_LOGIC_VECTOR (8 downto 0));
end gal_instrmapper;

architecture Behavioral of gal_instrmapper is

type rom16x10 is array(0 to 15) of std_logic_vector(8 downto 0);
constant mapper: rom16x10 := 
(
	0 => QREG & IOR & DZ, -- Q = channel[imm] (E = channel[A], F = channel[B])
	1 => NOP & IOR & ZQ, -- channel[imm] = Q  (E = channel[A], F = channel[B])
	2 => QREG & IOR & DZ, -- Q = imm
	3 => NOP & SUBR & DQ, -- Q - imm
	4 => QREG & ADD & DQ, -- Q = Q + imm
	5 => NOP & IOR & ZQ, -- A = 0, A++, A--, A = immediate, A = 0xC, A = 0xD, A = 0xE, A = 0xF, B...
	6 => RAMF & IOR & ZQ, -- reg[B+off] = Q
	7 => QREG & IOR & ZB, -- Q = reg[B+off]
	8 => QREG & ADD & AQ, -- Q = Q + reg[A+off] + Carry
	9 => QREG & SUBR & AQ, -- Q = Q - reg[A+off] + !Carry
	10 => QREG & LAND & AQ, -- Q = Q and reg[a+off]
	11 => QREG & IOR & AQ, -- Q = Q or reg[a+off]
	12 => QREG & EXOR & AQ, -- Q = Q xor reg[a+off]
	13 => am2901_noop, -- set / reset flags
	14 => am2901_noop, -- NOP
	15 => am2901_noop -- if (cond) goto ...
);

alias op_code: std_logic_vector(3 downto 0) is macro_i(7 downto 4);

begin
	micro_i <= mapper(to_integer(unsigned(op_code))) when execute = '1' else am2901_noop;
end Behavioral;

