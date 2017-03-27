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
           micro_i : out  STD_LOGIC_VECTOR (9 downto 0));
end gal_instrmapper;

architecture Behavioral of gal_instrmapper is

type rom16x10 is array(0 to 15) of std_logic_vector(9 downto 0);
constant mapper: rom16x10 := 
(
	0 => Y_DISABLE & QREG & IOR & DZ, -- Q = channel[imm] (E = channel[A], F = channel[B])
	1 => Y_ENABLE  & NOP & IOR & ZQ, -- channel[imm] = Q  (E = channel[A], F = channel[B])
	2 => Y_DISABLE & QREG & IOR & DZ, -- Q = imm
	3 => Y_DISABLE & NOP & SUBR & DQ, -- Q - imm
	4 => Y_DISABLE & QREG & ADD & DQ, -- Q = Q + imm
	5 => Y_ENABLE  & NOP & IOR & ZQ, -- NOP, A++, A--, A = Q, A = 0x0, A = 0x4, A = 0x8, A = 0xC, NOP, B++, B--, ...
	6 => Y_DISABLE & RAMU & IOR & ZB, -- X << reg[imm] << X (E = reg[A], F = reg[B])
	7 => Y_DISABLE & RAMD & IOR & ZB, -- X >> reg[imm] >> X (E = reg[A], F = reg[B])
	8 => Y_DISABLE & QREG & ADD & AQ, -- Q = Q + reg[imm] + Carry (E = reg[A], F = reg[B])
	9 => Y_DISABLE & QREG & SUBR & AQ, -- Q = Q - reg[imm] + !Carry (E = reg[A], F = reg[B])
	10 => Y_DISABLE & QREG & LAND & AQ, -- Q = Q and reg[imm] (E = reg[A], F = reg[B])
	11 => Y_DISABLE & QREG & IOR & AQ, -- Q = Q or reg[imm] (E = reg[A], F = reg[B])
	12 => Y_DISABLE & QREG & EXOR & AQ, -- Q = Q xor reg[imm] (E = reg[A], F = reg[B])
	13 => Y_DISABLE & RAMF & IOR & ZQ, -- reg[imm] = Q (E = reg[A], F = reg[B])
	14 => am2901_noop, -- set / reset flags
	15 => am2901_noop -- if (cond) goto ...
);

alias op_code: std_logic_vector(3 downto 0) is macro_i(7 downto 4);

begin
	micro_i <= mapper(to_integer(unsigned(op_code))) when execute = '1' else am2901_noop;
end Behavioral;

