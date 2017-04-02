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
			  step: in STD_LOGIC;
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
           micro_i : out  STD_LOGIC_VECTOR (9 downto 0));
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
           branch : buffer  STD_LOGIC;
			  callorreturn: buffer STD_LOGIC);
end component;

component gal_progcounter is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           macro_i : in  STD_LOGIC_VECTOR (7 downto 0);
           execute : in  STD_LOGIC;
           branch : in  STD_LOGIC;
			  callorreturn: in STD_LOGIC;
           pc : buffer  STD_LOGIC_VECTOR (9 downto 0));
end component;

component gal_conditionreg is
    Port ( clock : in  STD_LOGIC;
			  execute : in STD_LOGIC;
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           alu_c : in  STD_LOGIC;
           alu_z : in  STD_LOGIC;
           alu_v : in  STD_LOGIC;
           alu_n : in  STD_LOGIC;
           alu_x3 : inout  STD_LOGIC;
           alu_x0 : inout  STD_LOGIC;
           flags : buffer  STD_LOGIC_VECTOR (7 downto 0));
end component;

component gal_glue is
    Port ( 
			  reset: in STD_LOGIC;
			  clock: in STD_LOGIC;
			  i : in  STD_LOGIC_VECTOR (7 downto 0);
			  nRead: in STD_LOGIC;
			  nWrite: in STD_LOGIC;
			  nIo_Read: out STD_LOGIC;
			  nIo_Write: out STD_LOGIC;
           carry_in : in  STD_LOGIC;
           carry_out : out  STD_LOGIC;
			  execute: in STD_LOGIC;
			  ss_mode: in STD_LOGIC;
			  step: in STD_LOGIC;
			  ss_clock: out STD_LOGIC);
end component;

component gal_addrmux is
    Port ( i : in  STD_LOGIC_VECTOR (7 downto 0);
           addrA : in  STD_LOGIC_VECTOR (3 downto 0);
           addrB : in  STD_LOGIC_VECTOR (3 downto 0);
           addr_bus : out  STD_LOGIC_VECTOR (3 downto 0));
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
alias current_immediate: std_logic_vector(3 downto 0) is i(3 downto 0);

signal	addrA, addrB: std_logic_vector(3 downto 0);
signal	addrAIsZero, addrBIsZero: std_logic;

signal execute, callorreturn, branch: std_logic;

signal data_bus: std_logic_vector(3 downto 0);
signal addr_bus: std_logic_vector(3 downto 0);
signal flags: std_logic_vector(7 downto 0);
signal f_0: std_logic;
signal am2901_cin, am2901_cout, am2901_v, am2901_z, am2901_n, am2901_r3, am2901_r0: std_logic;
signal nOutputEnable: std_logic;

signal ss_clock: std_logic;

begin

	-- connect i/o address
	io_address <= addr_bus;
	
	-- status outputs
	status(4 downto 0) <= flags(4 downto 0); -- X N V Z C
	--status(0) <= clock;
	--status(1) <= flags(7);
	--status(2) <= step;
	--status(3) <= ss_clock;
	status(5) <= branch;
	status(6) <= execute;
	status(7) <= flags(7); -- Single step

	-- debug output
	debug_port(2 downto 0) <= microinstruction(2 downto 0);
	debug_port(3) <= '0';
	debug_port(6 downto 4) <= microinstruction(5 downto 3);
	debug_port(7) <= '0';
	debug_port(10 downto 8) <= microinstruction(8 downto 6);
	debug_port(15 downto 12) <= addr_bus; 
	
	-- f_0 is "open collector" but actually it implemented as tri-state or pull low
	am2901_z <= '1' when f_0 = '0' else '0';

glue: gal_glue port map
    ( 
	   reset => reset,
		clock => clock,
		i => i,
		nRead => nRead,
		nWrite => nWrite,
		nIo_Read => nIo_Read,
		nIo_Write => nIo_Write,
      carry_in => flags(0), -- carry flag bit from status register
      carry_out => am2901_cin, -- carry into Am2901
		execute => execute,
	   ss_mode => flags(7),
	   step => step,
		ss_clock => ss_clock
	 );
	 
addrmux: gal_addrmux port map
	(
		i => i,
		addrA => addrA,
		addrB => addrB,
		addr_bus => addr_bus
	);
	
progcounter: gal_progcounter port map 
   ( 
		reset => reset,
      clock => ss_clock,
      macro_i => i,
      execute => execute,
      branch => branch,
		callorreturn => callorreturn,
      pc => a
	);

instrmapper: gal_instrmapper port map
	(
		macro_i => i,
		execute => execute,
		micro_i(8 downto 0) => microinstruction,
		micro_i(9) => nOutputEnable
	);
	
data_mux: gal_datamux port map
	(
		i => i,
		data_in => io_data,
		data_out => data_bus,
		nRead => nRead,
		nWrite => nWrite
	);
	
indexreg_a: gal_indexreg port map 
		( 
         reset => reset,
			clock => ss_clock,
			sel => '0',
         macro_i => i,
			data => io_data,
         index => addrA,
         isZero => addrAisZero
		);

indexreg_b: gal_indexreg port map 
		( 
		   reset => reset,
			clock => ss_clock,
			sel => '1',
         macro_i => i,
			data => io_data,
         index => addrB,
         isZero => addrBIsZero
		);

brancher: gal_brancher Port map
		( 
			reset => reset,
         clock => ss_clock,
         i => i,
         condition(0) => flags(0), --F0: C, F8: !C
         condition(1) => flags(1), --F1: Z, F9: !Z
         condition(2) => flags(2), --F2: V, FA: !V
         condition(3) => flags(3), --F3: N, FB: !N
         condition(4) => flags(4), --F4: X, FC: !X
         condition(5) => addrAIsZero, --F5: A = 0, FD: A != 0
         condition(6) => addrBIsZero, --F6: B = 0, FE: B != 0
         condition(7) => '0', --F7: RETURN, FF: CALL
         execute => execute,
         branch => branch,
			callorreturn => callorreturn
		);
			  
conditionreg: gal_conditionreg port map
    ( 
			  clock => ss_clock,
			  execute => execute,
           i => i,
           alu_c => am2901_cout,
           alu_z => am2901_z,
           alu_v => am2901_v,
           alu_n => am2901_n,
           alu_x3 => am2901_r3,
           alu_x0 => am2901_r0,
           flags => flags
	  );
			    
slice: am2901 port map
    ( 
			  clk => ss_clock, 
           rst => reset,
           a => addr_bus, --addrA,
           b => addr_bus, --addrB,
           d => data_bus, --io_data,
           i => microinstruction(8 downto 0),
           c_n => am2901_cin, 
           oe => nOutputEnable,
           ram0 => am2901_r0,
           ram3 => am2901_r3,
           --qs0 => nc,
           --qs3 => nc,
           y => io_data,
           --g_bar => nc,
           --p_bar => nc,
           ovr => am2901_v,
           c_n4 => am2901_cout,
           f_0 => f_0,
           f3 => am2901_n
		);-----------------f(3) w/o 3-state

end Behavioral;

