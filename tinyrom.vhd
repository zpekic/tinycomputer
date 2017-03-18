----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:51:58 02/19/2017 
-- Design Name: 
-- Module Name:    tinyrom - Behavioral 
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
use STD.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tinyrom is
    Port ( address : in  STD_LOGIC_VECTOR (9 downto 0);
           data : out  STD_LOGIC_VECTOR (7 downto 0));
end tinyrom;

architecture Behavioral of tinyrom is

alias a6: std_logic_vector(5 downto 0) is address(5 downto 0);

type rom64x8 is array(0 to 63) of std_logic_vector(7 downto 0);

impure function char2hex(char: in character) return integer is
begin
	case char is
		when '0' to '9' =>
			return character'pos(char) - character'pos('0');
		when 'a' to 'f' =>
			return character'pos(char) - character'pos('a') + 10;
		when 'A' to 'F' =>
			return character'pos(char) - character'pos('A') + 10;
		when others =>
			assert false report "char2hex(): unexcpected character '" & char & "'" severity failure;
	end case;
	return 0;
end char2hex;

impure function init_bytememory(mif_file_name : in string; depth: in integer; default_value: std_logic_vector(7 downto 0)) return rom64x8 is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
	 variable char: character;
	 variable line_cnt: integer := 1;
	 variable isOk: boolean;
    variable temp_mem : rom64x8;-- := (others => (others => default));
	 variable byte_address: std_logic_vector(15 downto 0);
	 variable byte_value: std_logic_vector(7 downto 0);
	 variable hex_cnt: integer;
	 
begin
	 -- fill with default value
	 for i in 0 to depth - 1 loop	
		temp_mem(i) := default_value;
	 end loop;
	 report "init_mem(): initialized " & integer'image(depth) & " bytes of memory to " & integer'image(to_integer(unsigned(default_value))) severity note;
	 -- parse the file for the data
	 report "init_mem(): loading memory from file " & mif_file_name severity note;
	 while not endfile(mif_file) loop --till the end of file is reached continue.
      readline (mif_file, mif_line);
		--next when mif_line'length = 0;  -- Skip empty lines
		report "init_mem(): line " & integer'image(line_cnt) & " read";
		isOk := true;
		hex_cnt := 0;
		while isOk = true loop
			read(mif_line, char, isOk);
			if (isOk) then
				case char is
					when ' ' =>
						report "init_mem(): space detected";
					when ';' =>
						report "init_mem(): comment detected, rest is ignored";
						exit;
					when '0' to '9'|'a' to 'f'|'A' to 'F' =>
						--report "init_mem(): hex char detected";
						case hex_cnt is
							when 0 =>
								byte_address := x"000" & std_logic_vector(to_unsigned(char2hex(char), 4));
							when 1|2 =>
								byte_address := byte_address(11 downto 0) & std_logic_vector(to_unsigned(char2hex(char), 4));
							when 3 =>
								byte_address := byte_address(11 downto 0) & std_logic_vector(to_unsigned(char2hex(char), 4));
								report "init_mem(): address parsed";
							when 4 =>
								byte_value := x"0" & std_logic_vector(to_unsigned(char2hex(char), 4));
							when 5 =>
								byte_value := byte_value(3 downto 0) & std_logic_vector(to_unsigned(char2hex(char), 4));
								temp_mem(to_integer(unsigned(byte_address)) + 0) := byte_value;
								report "init_mem(): 1st byte set";
							when 6 =>
								byte_value := x"0" & std_logic_vector(to_unsigned(char2hex(char), 4));
							when 7 =>
								byte_value := byte_value(3 downto 0) & std_logic_vector(to_unsigned(char2hex(char), 4));
								temp_mem(to_integer(unsigned(byte_address)) + 1) := byte_value;
								report "init_mem(): 2nd byte set";
							when others =>
								assert false report "init_mem(): too many bytes specified in line" severity failure; 
						end case;
						hex_cnt := hex_cnt + 1;
					when others =>
						assert false report "init_mem(): unexpected char in line " & integer'image(line_cnt) severity failure; 
				end case;
			else
				report "init_mem(): end of line " & integer'image(line_cnt) & " reached";
			end if;
		end loop;
		
		line_cnt := line_cnt + 1;
	end loop; -- next line in file
 
	file_close(mif_file);
	
	for i in 0 to depth - 1 loop	
		--write(dbg_line, i);
		--write(dbg_line, temp_mem(i));
		--writeline(dbg_file, dbg_line);
		report integer'image(to_integer(unsigned(temp_mem(i))));
   end loop;
	--file_close(dbg_file);
		
   return temp_mem;
end init_bytememory;

constant prog_from_file: rom64x8 := init_bytememory("testprog\prog1.mif", 64, x"FF");

constant prog_from_inline: rom64x8 := 
(
	0 => x"54", -- A=0
	1 => x"5C", -- B=0
	2 => x"0E", -- Q = port[A]
	3 => x"1E", -- port[A] = Q
	4 => x"51", -- A++
	5 => x"0E", -- Q = port[A]
	6 => x"1E", -- Q=port[A]
	7 => x"51", -- A++
	8 => x"0E", -- Q = port[A]
	9 => x"1E", -- port[A] = Q
	10 => x"51", -- A++
	11 => x"0E", -- Q = port[A]
	12 => x"1E", -- port[A] = Q
	13 => x"51", -- A++
	14 => x"0E", -- Q = port[A]
	15 => x"1E", -- port[A] = Q

	16 => x"58", -- loopB: B=0
	17 => x"59", -- B++
	18 => x"59", -- B++
	19 => x"59", -- B++
	20 => x"59", -- B++
	21 => x"54", -- A=0
	22 => x"0E", -- loopA: Q=port[A]
	23 => x"4F", -- Q--
	24 => x"1E", -- port[A]=Q
	25 => x"51", -- A++
	26 => x"5A", -- B--
	27 => x"F9", -- IF(B != 0) GOTO loopA
	28 => x"FA", -- 
	29 => x"FE", -- GOTO loopB
	30 => x"F2", -- 
	31 => x"FF", -- STOP
	
	others => x"FF" -- STOP (deadloop: GOTO deadloop)
);

begin
	data <= prog_from_file(to_integer(unsigned(a6)));
	--data <= x"FF";	
--	data(7 downto 4) <= "000" & address(0);
--	data(3 downto 0) <= address(3 downto 0); --"00" & address(2) & address(1);

end Behavioral;

