----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:36:33 03/06/2016 
-- Design Name: 
-- Module Name:    aclock - structural 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aclock is
    Port ( reset : in  STD_LOGIC;
			  onehertz: in STD_LOGIC;

			  select_alarm: in  STD_LOGIC;
			  enable_alarm: in  STD_LOGIC;
			  select_12hr: in  STD_LOGIC;
			  enable_set: in  STD_LOGIC;
			  
           set_hr: in STD_LOGIC;
           set_min: in STD_LOGIC;
           set_inc: in STD_LOGIC;
           set_dec: in STD_LOGIC;
			  key_code : in STD_LOGIC_VECTOR(3 downto 0);
			  key_hit : in STD_LOGIC;

           hrmin_bcd : out  STD_LOGIC_VECTOR (15 downto 0);
			  is_pm: out STD_LOGIC;
           alarm_active : out  STD_LOGIC;
			  debug_port: out STD_LOGIC_VECTOR(3 downto 0));
end aclock;

use work.hourminbcd;
use work.comparatorwithstate;
use work.counterwithlimit;
use work.mux32to16;

architecture structural of aclock is

component bcd_counter is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           set : in  STD_LOGIC;
           inc : in  STD_LOGIC;
           dec : in  STD_LOGIC;
           maxval : in  STD_LOGIC_VECTOR (7 downto 0);
			  setval : in  STD_LOGIC_VECTOR (3 downto 0);
           is_zero : out  STD_LOGIC;
           is_maxval : out  STD_LOGIC;
           bcd : out  STD_LOGIC_VECTOR (7 downto 0)
			);
end component;

component counterwithlimit is
    Port ( clock : in  STD_LOGIC;
           clear : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
			  set: in STD_LOGIC;
           limit : in  STD_LOGIC_VECTOR (3 downto 0);
           out_count : out  STD_LOGIC_VECTOR (3 downto 0);
           out_zero : out  STD_LOGIC;
           out_limit : out  STD_LOGIC
			 );
end component;

component hourminbcd is
    Port ( reset : in  STD_LOGIC;
           sync : in  STD_LOGIC;
			  pulse: in STD_LOGIC;
			  
			  set_hr : in  STD_LOGIC;
           set_min : in  STD_LOGIC;
           set_inc : in  STD_LOGIC;
           set_dec : in  STD_LOGIC;
			  key_code : in STD_LOGIC_VECTOR(3 downto 0);
			  key_hit : in STD_LOGIC;

           bcdout : out  STD_LOGIC_VECTOR (15 downto 0);
			  debug: out STD_LOGIC_VECTOR(3 downto 0)
			);
end component;

component comparatorwithstate is
    Port ( a : in  STD_LOGIC_VECTOR (23 downto 0);
           b : in  STD_LOGIC_VECTOR (23 downto 0);
			  clock: in STD_LOGIC;
           reset : in  STD_LOGIC;
			  enable: in STD_LOGIC;
           trigger : out  STD_LOGIC
			);
end component;

component mux32to16
    Port ( a : in  STD_LOGIC_VECTOR (15 downto 0);
           b : in  STD_LOGIC_VECTOR (15 downto 0);
           s : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (15 downto 0)
			 );
end component;

component converter24to12
    Port ( select_12hr : in  STD_LOGIC;
           hour24 : in  STD_LOGIC_VECTOR (7 downto 0);
           hour_ispm : out  STD_LOGIC;
           hour_12or24 : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

-- common
signal mode_clock: std_logic;
signal resetbuzzer: std_logic;
signal minup: std_logic;
signal key_mode: std_logic;
signal resetseconds: std_logic;
signal hr24_bcd: std_logic_vector(7 downto 0);

-- seconds
signal secvalue: std_logic_vector(7 downto 0);
-- clock
signal clock_bcd: std_logic_vector(15 downto 0);
signal clock_ispm: std_logic;
signal clock_set_hr, clock_set_min, clock_set_inc, clock_set_dec: std_logic;
signal debug_clock: std_logic_vector(3 downto 0);
-- alarm
signal alarm_bcd: std_logic_vector(15 downto 0);
signal alarm_ispm: std_logic;
signal alarm_set_hr, alarm_set_min, alarm_set_inc, alarm_set_dec: std_logic;
signal debug_alarm: std_logic_vector(3 downto 0);


begin
   resetbuzzer <= reset or set_hr or set_min or set_inc or set_dec; -- any button push should kill the alarm
	resetseconds <= reset or set_min; -- when setting minutes, keep seconds at 0

	-- enable clock
	clock_set_hr <= enable_set and set_hr and (not select_alarm); 
	clock_set_min <= enable_set and set_min and (not select_alarm); 
	clock_set_inc <= enable_set and set_inc and (not select_alarm); 
	clock_set_dec <= enable_set and set_dec and (not select_alarm);
	-- enable alarm
	alarm_set_hr <= enable_set and set_hr and select_alarm; 
	alarm_set_min <= enable_set and set_min and select_alarm; 
	alarm_set_inc <= enable_set and set_inc and select_alarm; 
	alarm_set_dec <= enable_set and set_dec and select_alarm;
	
	-- DEBUG
	debug_port <= debug_alarm when select_alarm = '1' else debug_clock;
	
	-- SECONDS
	sec: bcd_counter port map (
				  reset => resetseconds,
				  clk => onehertz,
				  set => '0',
				  inc => '1',
				  dec => '0',
				  maxval => X"59",
				  setval => X"0",
              is_maxval => minup,
				  bcd => secvalue
	);
	
   -- CLOCK
	clock: hourminbcd port map ( 
			  reset => reset,
           sync => onehertz,
			  pulse => minup,

           set_hr => clock_set_hr,
           set_min => clock_set_min,
           set_inc => clock_set_inc,
           set_dec => clock_set_dec,
			  key_code => key_code,
			  key_hit => key_hit,

           bcdout => clock_bcd,
			  debug => debug_clock
			  );
   -- ALARM
	alarm: hourminbcd port map ( 
			  reset => reset,
           sync => onehertz,
			  pulse => '0',

           set_hr => alarm_set_hr,
           set_min => alarm_set_min,
           set_inc => alarm_set_inc,
           set_dec => alarm_set_dec,
			  key_code => key_code,
			  key_hit => key_hit,

           bcdout => alarm_bcd,
			  debug => debug_alarm
			  );
	-- COMPARATOR
	buzzer: comparatorwithstate port map (
				a(23 downto 8) => clock_bcd,
				a(7 downto 0) => secvalue,
				b(23 downto 8) => alarm_bcd,
				b(7 downto 0) => "00000000",
				clock => onehertz, -- check for alarm every sec, to make sure it is triggered as minute starts 
				reset => resetbuzzer,
				enable => enable_alarm,
				trigger => alarm_active
				);
   -- OUTPUT 
	mux: mux32to16 port map (
								a => clock_bcd,
								b => alarm_bcd,
								y(7 downto 0) => hrmin_bcd(7 downto 0), -- minutes are displayed directly
								y(15 downto 8) => hr24_bcd(7 downto 0), -- hours go through optional 24 to 12am/pm conversion
								s => select_alarm
									);
				
	convert2ampm: converter24to12 port map (
			select_12hr => select_12hr,
         hour24 => hr24_bcd(7 downto 0),
         hour_ispm => is_pm,
         hour_12or24 => hrmin_bcd(15 downto 8)
							);
end structural;

