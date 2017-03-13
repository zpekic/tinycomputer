----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:21:44 11/15/2016 
-- Design Name: 
-- Module Name:    bin2bcd - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bin2bcd is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           bcd_mode : in  STD_LOGIC;
           input_ready : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (15 downto 0);
           output_ready : out  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (19 downto 0);
			  debug: out STD_LOGIC_VECTOR(3 downto 0)
			);
end bin2bcd;

architecture fsm of bin2bcd is

component bcdadder is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           cin : in  STD_LOGIC;
           sum : out  STD_LOGIC_VECTOR (3 downto 0);
           cout : out  STD_LOGIC);
end component;

type state is (st_reset, st_ready, st_start, st_sync, st_busy, st_done);
signal current_state, next_state: state;

signal c0, c1, c2, c3: std_logic;
--signal val_mux: std_logic;
signal shifter: std_logic_vector(15 downto 0);
signal rom_mux, bcd_accu, bcd_val: std_logic_vector(19 downto 0);
signal counter: std_logic_vector(4 downto 0);
type rom16x20 is array (0 to 15) of std_logic_vector(19 downto 0);
constant powersof2: rom16x20 := (
	X"00001",
	X"00002",
	X"00004",
	X"00008",
	X"00016",
	X"00032",
	X"00064",
	X"00128",
	X"00256",
	X"00512",
	X"01024",
	X"02048",
	X"04096",
	X"08192",
	X"16384",
	X"32767");

begin

debug(3) <= '1' when (current_state = st_ready) else '0';
debug(2) <= '1' when (current_state = st_start) else '0';
debug(1) <= '1' when (current_state = st_busy) else '0';
debug(0) <= '1' when (current_state = st_done) else '0';
	
output <= bcd_accu when (bcd_mode = '1') else X"0" & input;
output_ready <= '1' when ((bcd_mode = '1' and current_state = st_done) or (bcd_mode = '0' and input_ready = '1')) else '0';

rom_mux <= powersof2(to_integer(unsigned(counter(4 downto 1)))) when shifter(0) = '1' else X"00000";

-- hook up BCD adders with ripple carry
a0: bcdadder port map (
	a => rom_mux(3 downto 0),
	b => bcd_accu(3 downto 0),
	cin => '0',
	sum => bcd_val(3 downto 0),
	cout => c0
);
a1: bcdadder port map (
	a => rom_mux(7 downto 4),
	b => bcd_accu(7 downto 4),
	cin => c0,
	sum => bcd_val(7 downto 4),
	cout => c1
);
a2: bcdadder port map (
	a => rom_mux(11 downto 8),
	b => bcd_accu(11 downto 8),
	cin => c1,
	sum => bcd_val(11 downto 8),
	cout => c2
);
a3: bcdadder port map (
	a => rom_mux(15 downto 12),
	b => bcd_accu(15 downto 12),
	cin => c2,
	sum => bcd_val(15 downto 12),
	cout => c3
);
a4: bcdadder port map (
	a => rom_mux(19 downto 16),
	b => bcd_accu(19 downto 16),
	cin => c3,
	sum => bcd_val(19 downto 16)
	--cout => NC
);

fsm_lower: process(clk, reset, input)
begin
	if (reset = '1') then
		current_state <= st_reset;
	else
		if (rising_edge(clk)) then
			counter <= std_logic_vector(unsigned(counter) + 1);
			current_state <= next_state;
			if (current_state = st_start) then
				bcd_accu <= X"00000";
				shifter <= input;
			end if;
			if (current_state = st_busy and counter(0) = '1') then
				bcd_accu <= bcd_val;
			end if;
			if (current_state = st_busy and counter(0) = '1') then
				shifter <= '0' & shifter(15 downto 1);
			end if;
		end if;
	end if;
end process;
	
fsm_upper: process(current_state, input_ready, counter)
begin
	case current_state is
		when st_reset =>
			next_state <= st_ready;
		when st_ready =>
			if (input_ready = '1') then
				next_state <= st_start;
			else
				next_state <= st_ready;
			end if;
		when st_start =>
			next_state <= st_sync;
		when st_sync =>
			if (counter = "11111") then
				next_state <= st_busy;
			else
				next_state <= st_sync;
			end if;
		when st_busy =>
			if (shifter = X"0000") then
				next_state <= st_done;
			else
				next_state <= st_busy;
			end if;
		when st_done =>
				next_state <= st_ready;
	end case;
end process;

end fsm;

