LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE work.systolic_package.all; 

ENTITY STPU IS
PORT( clock, reset, hard_reset, setup, go, stall: IN STD_LOGIC;
		weights, a_in : IN UNSIGNED(23 DOWNTO 0);
		done : out STD_LOGIC;
		y0, y1, y2 : OUT bus_type);
END STPU;

ARCHITECTURE Structure OF STPU IS

COMPONENT MMU IS
PORT( clock, reset, hard_reset, ld, ld_w_stall : IN STD_LOGIC;
		a0, a1, a2, w0, w1, w2 : IN UNSIGNED(7 DOWNTO 0);
		y0, y1, y2 : OUT UNSIGNED(7 DOWNTO 0));
END COMPONENT;

COMPONENT WRAM IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ActivationUnit IS
GENERIC( matrixSize : UNSIGNED := "011" );
PORT( clock, reset, hard_reset, stall, data_start : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		done : out STD_LOGIC;
		row0, row1, row2 : OUT bus_type);
END COMPONENT;

SIGNAL loadState : UNSIGNED(1 DOWNTO 0) := "00";
SIGNAL wram_addr, uram_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL wram_read, uram_read, wram_write, uram_write, wram_clr, uram_clr : STD_LOGIC;
SIGNAl w_data_in: STD_LOGIC_VECTOR(23 DOWNTO 0);
BEGIN

wr : WRAM PORT MAP(aclr => open, address => wram_addr, clock => clock, data => w_data_in, rden => wram_read, wren => wram_write, q => open);

w_data_in <= STD_LOGIC_VECTOR(weights);
wram_addr <= STD_LOGIC_VECTOR(loadState);
wram_write <= loadState(1) OR loadState(0);

PROCESS(clock)
BEGIN
	IF(rising_edge(clock)) THEN
		IF(setup = '1' AND loadState = "00") THEN
			loadState <= "01";
		END IF;
		IF(loadState = "10") THEN
			loadState <= "00";
		ELSIF(NOT loadState = "00") THEN
			loadState <= loadState + 1;
		END IF;
	END IF;

END PROCESS;



END Structure;
