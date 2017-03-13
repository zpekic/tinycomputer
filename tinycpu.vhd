----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:48:09 02/19/2017 
-- Design Name: 
-- Module Name:    tinycpu - Behavioral 
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

entity tinycpu is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           a : out  STD_LOGIC_VECTOR (9 downto 0);
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           io_data : inout  STD_LOGIC_VECTOR (3 downto 0);
           nIo_read : buffer  STD_LOGIC;
           nIo_write : buffer  STD_LOGIC;
           io_address : buffer  STD_LOGIC_VECTOR (3 downto 0);
           status : out  STD_LOGIC_VECTOR (7 downto 0);
           debug_port : out  STD_LOGIC_VECTOR (15 downto 0));
end tinycpu;

architecture Behavioral of tinycpu is

component gal_datamux is
    Port ( i : in  STD_LOGIC_VECTOR (7 downto 0);
           data_in : in  STD_LOGIC_VECTOR (3 downto 0);
           data_out : out  STD_LOGIC_VECTOR (3 downto 0);
           nRead : out  STD_LOGIC;
           nWrite : out  STD_LOGIC);
end component;

component gal_instrmapper is
    Port ( macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : in  STD_LOGIC;
           micro_i : out  STD_LOGIC_VECTOR (8 downto 0));
end component;

component gal_indexreg is
    Port ( reset : in  STD_LOGIC;
			  clock : in  STD_LOGIC;
			  sel : in STD_LOGIC;
           macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  data: in STD_LOGIC_VECTOR(3 downto 0);
           index : out  STD_LOGIC_VECTOR (3 downto 0);
           isZero : out  STD_LOGIC);
end component;

component gal_brancher is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           condition : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : buffer  STD_LOGIC;
           branch : buffer  STD_LOGIC);
end component;

component gal_progcounter is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : in  STD_LOGIC;
           branch : in  STD_LOGIC;
           pc : buffer  STD_LOGIC_VECTOR (9 downto 0));
end component;

component am2901 is
    Port ( clk : in  STD_LOGIC; 
           rst : in  STD_LOGIC;
           a : in  std_logic_vector (3 downto 0);----address  inputs
           b : in  STD_LOGIC_VECTOR (3 downto 0);----address inputs
           d : in  STD_LOGIC_VECTOR (3 downto 0);----direct data
           i : in  STD_LOGIC_VECTOR (8 downto 0);---micro instruction
           c_n : in  STD_LOGIC;---------------------carry in
           oe : in  STD_LOGIC;----------------------output enable
           ram0 : inout  STD_LOGIC;-----------------shift lines to ram
           ram3 : inout  STD_LOGIC;-----------------shift lines to ram
           qs0 : inout  STD_LOGIC;------------------shift lines to q
           qs3 : inout  STD_LOGIC;------------------shift lines to q
           y : inout  STD_LOGIC_VECTOR (3 downto 0);-------data outputs(3-state)
           g_bar : buffer  STD_LOGIC;---------------carry generate
           p_bar : buffer  STD_LOGIC;---------------carry propagate
           ovr : buffer  STD_LOGIC;-----------------overflow
           c_n4 : buffer  STD_LOGIC;----------------carry out
           f_0 : buffer  STD_LOGIC;-----------------f = 0
           f3 : buffer  STD_LOGIC);-----------------f(3) w/o 3-state
end component;

signal pc: std_logic_vector(9 downto 0);
signal nRead, nWrite: std_logic := '1';
signal microinstruction: std_logic_vector(8 downto 0);
alias current_opcode: std_logic_vector(3 downto 0) is i(7 downto 4);
signal	addrA, addrB: std_logic_vector(3 downto 0);
signal	addrAIsZero, addrBIsZero: std_logic;

signal execute, branch: std_logic;

signal data_bus: std_logic_vector(3 downto 0);
signal cIn: std_logic;
signal shiftbit: std_logic;

begin

	-- status outputs
	status(0) <= not nRead;
	status(1) <= not nWrite;
	status(2) <= addrAIsZero;
	status(3) <= addrBIsZero;
	status(7 downto 4) <= io_address;
	
	-- channels 0..13 are immediate, but 14 and 15 come from A and B regs
	with i(3 downto 0) select
		io_address <=	addrA when "1110",
							addrB when "1111",
							std_logic_vector(i(3 downto 0)) when others;
	-- TODO: replace with CIn Mux
	cIn <= '1' when (current_opcode = std_logic_vector(opcode_CPQ)) else '0';
	nIo_read <= nRead; --'0' when (current_opcode = opcode_inp) else '1';
	nIo_write <= nWrite or clock; --'0' when (current_opcode = opcode_out) else '1';

	debug_port(2 downto 0) <= microinstruction(2 downto 0);
	debug_port(3) <= '0';
	debug_port(6 downto 4) <= microinstruction(5 downto 3);
	debug_port(7) <= '0';
	debug_port(10 downto 8) <= microinstruction(8 downto 6);
	debug_port(15 downto 12) <= data_bus; --io_data; --"00" & nIo_read & nIo_write;
	
progcounter: gal_progcounter port map 
   ( 
		reset => reset,
      clock => clock,
      macro_i => i,
      execute => execute,
      branch => branch,
      pc => a
	);

instrmapper: gal_instrmapper port map
	(
		macro_i => i,
		execute => execute,
		micro_i => microinstruction
	);
	
data_mux: gal_datamux port map
	(
		i => i,
		data_in => io_data,
		data_out => data_bus,
		nRead => nRead,--nIo_Read,
		nWrite => nWrite--nIo_write
	);
	
indexreg_a: gal_indexreg port map 
		( 
         reset => reset,
			clock => clock,
			sel => '0',
         macro_i => i,
			data => io_data,
         index => addrA,
         isZero => addrAisZero
		);

indexreg_b: gal_indexreg port map 
		( 
         reset => reset,
			clock => clock,
			sel => '1',
         macro_i => i,
			data => io_data,
         index => addrB,
         isZero => addrBIsZero
		);

brancher: gal_brancher Port map
		( 
			reset => reset,
         clock => clock,
         i => i,
         condition(0) => '0', --F0: X, F8: !X
         condition(1) => '0',	--F1: C, F9: !C
         condition(2) => '0', --F2: Z, FA: !Z
         condition(3) => '0', --F3: V, FB: !V
         condition(4) => '0', --F2: N, FC: !N
         condition(5) => addrAIsZero, --F5: A = 0, FD: A != 0
         condition(6) => addrBIsZero, --F6: B = 0, FE: B != 0
         condition(7) => '0', --F7: never (false), FF: always (true)
         execute => execute,
         branch => branch
		);
			  
slice: am2901 port map
    ( 
			  clk => clock, 
           rst => reset,
           a => addrA,
           b => addrB,
           d => data_bus, --io_data,
           i => microinstruction(8 downto 0),
           c_n => cIn, --hardcode 1 for now to make CPQ work, otherwise 0
           oe => nWrite,--nIo_write,
           ram0 => shiftbit,
           --ram3 => "Z",
           --qs0 => "Z",
           qs3 => shiftbit,
           y => io_data
           --g_bar => nc,
           --p_bar => nc,
           --ovr => status(0),
           --c_n4 => status(1),
           --f_0 => status(2),
           --f3 => status(3)
		);-----------------f(3) w/o 3-state

end Behavioral;

