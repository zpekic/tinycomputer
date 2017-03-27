--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package tinycpu_common is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

constant QREG, ADD, AQ: std_logic_vector(2 downto 0) := "000";
constant NOP, SUBR, AB: std_logic_vector(2 downto 0) := "001";
constant RAMA, SUBS, ZQ: std_logic_vector(2 downto 0) := "010";
constant RAMF, IOR, ZB: std_logic_vector(2 downto 0) := "011";
constant RAMQD, LAND, ZA: std_logic_vector(2 downto 0) := "100";
constant RAMD, NOTRS, DA: std_logic_vector(2 downto 0) := "101";
constant RAMQU, EXOR, DQ: std_logic_vector(2 downto 0) := "110";
constant RAMU, EXNOR, DZ: std_logic_vector(2 downto 0) := "111";

constant Y_ENABLE: std_logic := '0';
constant Y_DISABLE: std_logic := '1';

constant am2901_noop: std_logic_vector(9 downto 0) := Y_DISABLE & NOP & IOR & DZ; -- (137)

constant opcode_INP: unsigned := x"0"; -- Q = port[0..13], Q = port[A], Q = port[B]
constant opcode_OUT: unsigned := x"1"; -- port[0..13] = Q, port[A] = Q, port[B] = Q
constant opcode_LDQ: unsigned := x"2"; -- load immediate
constant opcode_CPQ: unsigned := x"3"; -- compare immediate
constant opcode_ADQ: unsigned := x"4"; -- add quick
constant opcode_IRO: unsigned := x"5"; -- index register operations
constant opcode_RTL: unsigned := x"6"; -- rotate left ( *2)
constant opcode_RTR: unsigned := x"7"; -- rotate right ( /2)
constant opcode_ADC: unsigned := x"8"; -- add with carry
constant opcode_SBC: unsigned := x"9"; -- subtract with !carry
constant opcode_AND: unsigned := x"A"; -- logical and
constant opcode_IOR: unsigned := x"B"; -- logical or
constant opcode_XOR: unsigned := x"C"; -- logical xor
constant opcode_XRR: unsigned := x"D"; -- logical xor (destination to register)
constant opcode_FLG: unsigned := x"E"; -- flag operations (set, reset)
constant opcode_BRA: unsigned := x"F"; -- branch / call / return instructions

constant tinycpu_NOPA: std_logic_vector(7 downto 0) := x"50";
constant tinycpu_NOPB: std_logic_vector(7 downto 0) := x"58";

end tinycpu_common;

package body tinycpu_common is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end package body;
