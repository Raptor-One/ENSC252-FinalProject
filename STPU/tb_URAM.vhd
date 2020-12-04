LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY tb_URAM IS
END tb_URAM;

ARCHITECTURE test of tb_URAM IS

COMPONENT URAM IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL aclr_sig, clock_sig, rden_sig, wren_sig : STD_LOGIC;
SIGNAL address_sig : STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL data_sig, q_sig : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN

DUT: URAM
PORT MAP (aclr => aclr_sig, address => address_sig, clock => clock_sig, data => data_sig, rden => rden_sig, wren => wren_sig, q => q_sig);

PROCESS IS

PROCEDURE CLOCK_W_DATA(constant addr : IN STD_LOGIC_VECTOR (1 DOWNTO 0); constant d : IN INTEGER) IS
BEGIN
clock_sig <= '0';
address_sig <= addr;
data_sig <= STD_LOGIC_VECTOR(TO_UNSIGNED(d,8));
wait for 20 ns;
clock_sig <= '1';
wait for 20 ns;
END PROCEDURE;

PROCEDURE CLOCK IS
BEGIN
clock_sig <= '0';
wait for 20 ns;
clock_sig <= '1';
wait for 20 ns;
END PROCEDURE;

BEGIN 
-- setup
aclr_sig <= '0';
clock_sig <= '0';
rden_sig <= '0';
wren_sig <= '0';
address_sig <= "00";
data_sig <= (others => '0');
wait for 20 ns;

-- write data into all adresses - write will be registered on next rising edge
wren_sig <= '1';
CLOCK_W_DATA("00",255);
CLOCK_W_DATA("01",128);
CLOCK_W_DATA("10",100);
CLOCK_W_DATA("11",50);

--read from all adresses - output will only change to new value after 2 rising edges
rden_sig <= '1';
wren_sig <= '0';
CLOCK_W_DATA("00",0);
CLOCK_W_DATA("01",0);
CLOCK_W_DATA("10",0);
CLOCK_W_DATA("11",0);
CLOCK;

--test read and write both on - first rising edge will write new value (but not change output, still at old value), second rising edge will now output new value
rden_sig <= '1';
wren_sig <= '1';
CLOCK_W_DATA("00",101);
CLOCK;

--test aclr (no clock change) - just clears current output, doesnt modify data
rden_sig <= '0';
wren_sig <= '0';
aclr_sig <= '1';
wait for 20 ns;
aclr_sig <= '0';

--read from all adresses again - the first rising edge after a clear will just have data that it was outputting before the clear, after second rising edge, it will output actual value for approriate adress
rden_sig <= '1';
wren_sig <= '0';
CLOCK_W_DATA("11",0);
CLOCK_W_DATA("01",0);
CLOCK_W_DATA("10",0);
CLOCK_W_DATA("00",0);
CLOCK;

--both control signals disabled - holds last value
rden_sig <= '0';
wren_sig <= '0';
CLOCK;
CLOCK;

WAIT;
END PROCESS;

END test;