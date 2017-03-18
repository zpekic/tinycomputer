----------------------------------------------------------------------------------
-- Company: @Home
-- Engineer: Zoltan Pekic (zpekic@hotmail.com)
-- 
-- Create Date:    12:26:24 02/07/2016 
-- Design Name: 
-- Module Name:    alarmclock - structural 
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tinycomputer is
	port(
		-- 50MHz on the Mercury board
		CLK: in std_logic;
		-- Master reset button on Mercury board
		USR_BTN: in std_logic; 
		-- Switches on baseboard
		-- SW0 - select alarm (on) or clock (off) to view or set
		-- SW1 - enable alarm (on)
		-- SW2 - 12hr mode (on), or 24hr mode (off)
		-- SW3 - enable ADC display (on), or enable clock/alarm (off)
		-- SW4 - keyboard mode, dec(on), hex(off)
		-- SW5 - not used
		-- SW6 - 7seg dimmer mode select (or ADC channel to display value)
		-- SW7 - 7seg dimmer mode select (or ADC channel to display value)
		-- dimmer mode -- SW7 -- SW6 --
		-- potentiometer	on		 on
		-- light sensor   on 	 off
		-- temperature    off    on
		-- on (max light) off    off
      -------------------------------	
		SW: in std_logic_vector(7 downto 0); 
		-- Push buttons on baseboard
		-- BTN3 - press to set hour for either alarm or clock
		-- BTN2 - press to set minutes for either alarm or clock
		-- BTN1 - decrement hour or minute by one each second (depending on BTN3 or BTN2)
		-- BTN0 - increment hour or minute by one each second (depending on BTN3 or BTN2)
		-- also push any of these to dismiss alarm
		BTN: in std_logic_vector(3 downto 0); 
		-- Stereo audio output on baseboard, used to output sound if alarm is triggered
		--AUDIO_OUT_L, AUDIO_OUT_R: out std_logic;
		-- 7seg LED on baseboard to display clock or alarm
		A_TO_G: out std_logic_vector(6 downto 0); 
		AN: out std_logic_vector(3 downto 0); 
		-- dot on digit 0 is lit up - PM if in 12hr mode
		-- dot on digit 2 is lit up - 1Hz blicking if clock or steady if alarm is displayed
		DOT: out std_logic; 
		-- 4 LEDs on Mercury board will "count" (alarm enabled but not triggered), "flash" (alarm triggered) or be off (alarm disabled)
		--LED: out std_logic_vector(3 downto 0);
		LED: out std_logic_vector(3 downto 0);
		-- ADC interface
		ADC_MISO: in std_logic;
		ADC_MOSI: out std_logic;
		ADC_SCK: out std_logic;
		ADC_CSN: out std_logic;
		-- PMOD interface (for hex keypad)
		PMOD: inout std_logic_vector(7 downto 0)
		-- VGA
		--HSYNC: out std_logic;
		--VSYNC: out std_logic;
		--RED: out std_logic_vector(2 downto 0);
		--GRN: out std_logic_vector(2 downto 0);
		--BLU: out std_logic_vector(1 downto 0)
	);
end tinycomputer;

use work.clock_divider;
use work.mux16to4;
use work.mux32to16;
use work.fourdigitsevensegled;
use work.tinycpu;
use work.tinyrom;
use work.pwm10bit;
use work.PmodKYPD;
use work.debouncer;


architecture structural of tinycomputer is

component clock_divider is
    Port ( reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           div : out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end component;

component mux16to4 is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           c : in  STD_LOGIC_VECTOR (3 downto 0);
           d : in  STD_LOGIC_VECTOR (3 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0);
			  nEnable : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (3 downto 0)
			 );
end component;

component mux32to16 is
    Port ( a : in  STD_LOGIC_VECTOR (15 downto 0);
           b : in  STD_LOGIC_VECTOR (15 downto 0);
           sel : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (15 downto 0)
			 );
end component;


component fourdigitsevensegled is
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
end component;

component pwm10bit is
    Port ( clk : in  STD_LOGIC;
			  adc_samplingrate: in STD_LOGIC;	
           adc_channel : in  STD_LOGIC_VECTOR (2 downto 0);
			  adc_miso : in  std_logic;         -- ADC SPI MISO
			  adc_mosi : out std_logic;         -- ADC SPI MOSI
			  adc_cs   : out std_logic;         -- ADC SPI CHIP SELECT
			  adc_clk  : out std_logic;         -- ADC SPI CLOCK
			  adc_value: out std_logic_vector(15 downto 0);
			  adc_valid: out std_logic;
           pwm_out : out  STD_LOGIC);
end component;

component PmodKYPD is
    Port ( 
           clk : in  STD_LOGIC;
			  reset: in STD_LOGIC;
			  bcdmode: in STD_LOGIC;
           Col : out  STD_LOGIC_VECTOR (3 downto 0);
			  Row : in  STD_LOGIC_VECTOR (3 downto 0);
           entry : out  STD_LOGIC_VECTOR (15 downto 0);
			  key_code : out STD_LOGIC_VECTOR(3 downto 0);
			  key_down: out STD_LOGIC
			 );
end component;

component debouncer is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           signal_in : in  STD_LOGIC;
           signal_out : out  STD_LOGIC);
end component;

component tinyrom is
    Port ( address : in  STD_LOGIC_VECTOR (9 downto 0);
           data : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component tinycpu is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           a : out  STD_LOGIC_VECTOR (9 downto 0);
           i : in  STD_LOGIC_VECTOR (7 downto 0);
           io_data : inout  STD_LOGIC_VECTOR (3 downto 0);
           nIo_read : buffer  STD_LOGIC;
           nIo_write : buffer  STD_LOGIC;
           io_address : out  STD_LOGIC_VECTOR (3 downto 0);
           status : out  STD_LOGIC_VECTOR (7 downto 0);
           debug_port : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

-- output data register
type port16by4 is array (15 downto 0) of std_logic_vector(3 downto 0);
signal data_port: port16by4;

-- common signals
signal clock: std_logic;
signal reset: std_logic;
signal address_bus: std_logic_vector(9 downto 0);
signal instruction_bus: std_logic_vector(7 downto 0);
signal io_bus: std_logic_vector(3 downto 0);
signal nIo_read: std_logic;
signal nIo_write: std_logic;
signal io_address_bus: std_logic_vector(3 downto 0);
signal status_bus: std_logic_vector(7 downto 0);
signal debug_cpu: std_logic_vector(15 downto 0);	
signal debug_bus: std_logic_vector(15 downto 0);	
signal display_bus: std_logic_vector(15 downto 0);

-- other signals
signal freq: std_logic_vector(3 downto 0);
signal debug_enable: std_logic;
signal debug_rom: std_logic;
signal led4: std_logic_vector(3 downto 0);
signal pushbutton: std_logic_vector(3 downto 0);
signal key_buff: std_logic_vector(15 downto 0);


-- ADC
signal adc_valid: std_logic;
signal adc_value: std_logic_vector(15 downto 0);
signal adc_ready: std_logic;
signal adc_output: std_logic_vector(19 downto 0);
-- dimmer
signal freq16, freq32, freq64, freq128: std_logic; -- use either to drive dimmer sample rate, keyboard etc.
signal led_dimmer: std_logic;
signal adc_to_pwm: std_logic;
signal adc_channel: std_logic_vector(2 downto 0);
-- kbd
signal key_code: std_logic_vector(3 downto 0);
signal key_down: std_logic;

begin
	-- common signals
	reset <= USR_BTN;
	clock <= (SW(7) and freq128) or ((not SW(7)) and freq(3));
	debug_enable <= SW(6);
	debug_rom <= SW(5);
	
	-- CPU
	tcpu: tinycpu port map 
	(
		clock => clock,
      reset => reset,
      a => address_bus,
      i => instruction_bus,
      io_data => io_bus,
      nIo_read => nIo_read,
      nIo_write => nIo_write,
      io_address => io_address_bus,
      status => status_bus,
      debug_port => debug_cpu	
	);
	-- PROGRAM ROM
	trom: tinyrom port map
	(
		address => address_bus,
		data => instruction_bus
	);
	
	-- Port I/O
	input_mux: mux16to4 port map (
		a => SW(3 downto 0),
		b => SW(7 downto 4),
		c => x"2",
		d => pushbutton,
		nEnable => nIo_read,
		sel => io_address_bus(1 downto 0),
		y => io_bus
	);
	
	write_port: process(reset, nio_write)
	begin
		if (reset = '1') then
			data_port(0) <= x"f";
			data_port(1) <= x"e";
			data_port(2) <= x"e";
			data_port(3) <= x"b";
		else
			if (rising_edge(nIo_write)) then
				--if (nIo_write = '0') then
					data_port(to_integer(unsigned(io_address_bus))) <= io_bus;
				--end if;
			end if;
		end if;
	end process;
	
	-- DIMMER (the mux generates the mapping of 2 switches to 3 out of 8 possible channels and the PWM signal routing)
	dimmer_mux: mux16to4 port map (
		a => "1000", -- full light on, adc channel is ignored
		b(3) => adc_to_pwm,
		b(2 downto 0) => "010", -- measure TEMP (adc channel 2)
		c(3) => adc_to_pwm, -- measure LIGHT (adc channel 3)
		c(2 downto 0) => "011", -- measure LIGHT (adc channel 3)
		d(3) => adc_to_pwm, -- measure POT (adc channel 4)
		d(2 downto 0) => "100", -- measure POT (adc channel 4)
		
		nEnable => '0',
		sel => SW(5 downto 4),
		
		y(3) => led_dimmer,
		y(2 downto 0) => adc_channel(2 downto 0)
	);

	-- FREQUENCY GENERATOR
	one_sec: clock_divider port map (
								clock => CLK,
								reset => reset,
								div(7) => freq(3), -- 1Hz
								div(6) => freq(2), -- 2Hz
								div(5) => freq(1), -- 4Hz
								div(4) => freq(0), -- 8Hz
								div(3) => freq16,  -- 16Hz
								div(2) => freq32,  -- 32Hz
								div(1) => freq64,  -- 64Hz
								div(0) => freq128  -- 128Hz
												);
	-- connect to 4 display LEDs
	muxled: mux16to4 port map (
								a => status_bus(3 downto 0),   -- no debug, status.low
								b => status_bus(7 downto 4),   -- no debug, status.high 
								c(3) => '1',   -- debug io
								c(2) => '1',
								c(1) => nIo_Read,
								c(0) => nIo_Write,
								d(3) => '1',   -- debug io
								d(2) => '1',
								d(1) => nIo_Read,
								d(0) => nIo_Write,
								y => led4,
								nEnable => '0',
								sel(1) => debug_enable,
								sel(0) => debug_rom
									);
	-- dim the LEDs just like the 7seg display
   LED(3) <= adc_to_pwm and led4(0);
   LED(2) <= adc_to_pwm and led4(1);
   LED(1) <= adc_to_pwm and led4(2);
   LED(0) <= adc_to_pwm and led4(3);


	-- DEBUG MUX
	debugmux: mux32to16 port map 
	(
		a => debug_cpu,
		b(15 downto 8) => address_bus(7 downto 0),
		b(7 downto 0) => instruction_bus,
		sel => debug_rom,
		y => debug_bus
	);
		
	-- MAIN DISPLAY MUX
	dispmux: mux32to16 port map (
								a(3 downto 0) => data_port(0),
								a(7 downto 4) => data_port(1),
								a(11 downto 8) => data_port(2),
								a(15 downto 12) => data_port(3),
								b => debug_bus,
								sel => debug_enable,
								y => display_bus
									);

	-- display on 4 seven-seg displays
	display: fourdigitsevensegled port map ( 
			  data => display_bus,
           digsel(1) => freq128,
			  digsel(0) => freq64,
           showsegments => led_dimmer,
           showdigit(3) => '1',
           showdigit(2) => '1',
           showdigit(1) => '1',
           showdigit(0) => '1',
           showdot(3) => '0',
			  showdot(2) => '0',
			  showdot(1) => '0',
			  showdot(0) => '0',
           anode => AN,
			  segment(7) => DOT,
           segment(6 downto 0) => A_TO_G
				);
				
   -- DIMMER converts ADC channel signal to pulse-width-modulated one to use for displays
   dimmer: pwm10bit Port map 
		   ( clk => CLK,
			  adc_samplingrate => freq64, -- 64Hz sampling rate	
			  adc_miso => ADC_MISO, -- ADC SPI MISO
			  adc_mosi => ADC_MOSI, -- ADC SPI MOSI
			  adc_cs   => ADC_CSN,  -- ADC SPI CHIP SELECT
			  adc_clk  => ADC_SCK,  -- ADC SPI CLOCK
           adc_channel => adc_channel, -- select light (011) or potentiometer (100)
			  adc_value => adc_value,
			  adc_valid => adc_valid,
           pwm_out => adc_to_pwm
			);
	
	-- Capture ADC reading for display
	--capture_adc: process(adc_ready)
	--begin
	--	if (rising_edge(adc_ready)) then
	--		debug16 <= adc_output(15 downto 0);
	--	end if;
	--end process;
	
	-- KEYBOARD
	kbd: PmodKYPD Port map
			( clk => freq64, -- 64Hz, means each key is sampled at 4Hz rate (64/16)
			  reset => reset,
			  bcdmode => SW(4),
           Col(3) => PMOD(0),
           Col(2) => PMOD(1),
           Col(1) => PMOD(2),
           Col(0) => PMOD(3),
			  Row(3) => PMOD(4),
			  Row(2) => PMOD(5),
			  Row(1) => PMOD(6),
			  Row(0) => PMOD(7),
           entry => key_buff,
			  key_code => key_code,
			  key_down => key_down			  
			);

	-- DEBOUNCE the 4 push buttons
	d0: debouncer port map (
		reset => reset,
		clock => freq128,
		signal_in => BTN(0),
		signal_out => pushbutton(0)
	);
	d1: debouncer port map (
		reset => reset,
		clock => freq128,
		signal_in => BTN(1),
		signal_out => pushbutton(1)
	);
	d2: debouncer port map (
		reset => reset,
		clock => freq128,
		signal_in => BTN(2),
		signal_out => pushbutton(2)
	);
	d3: debouncer port map (
		reset => reset,
		clock => freq128,
		signal_in => BTN(3),
		signal_out => pushbutton(3)
	);
				
end structural;

