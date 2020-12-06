LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE work.systolic_package.all;

ENTITY tb_STPU IS
END tb_STPU;

ARCHITECTURE test OF tb_STPU IS

COMPONENT STPU IS
PORT( clock, reset, hard_reset, setup, go, stall: IN STD_LOGIC;
		weights, a_in : IN UNSIGNED(23 DOWNTO 0);
		done : out STD_LOGIC;
		y0, y1, y2 : OUT bus_type);
END COMPONENT;
	
SIGNAL clock_sig, reset_sig, hard_reset_sig, setup_sig, go_sig, stall_sig, done_sig : STD_LOGIC;
SIGNAL weights_sig, a_in_sig : UNSIGNED(23 DOWNTO 0);
SIGNAL y0_sig, y1_sig, y2_sig : bus_type;

BEGIN
DUT: STPU
PORT MAP(clock => clock_sig, reset => reset_sig, hard_reset => hard_reset_sig, setup => setup_sig, go => go_sig, stall => stall_sig,
			weights => weights_sig, a_in => a_in_sig, done => done_sig, y0 => y0_sig, y1 => y1_sig, y2 => y2_sig);

PROCESS IS

PROCEDURE CLOCK_W_DATA_IN(constant w0 : IN INTEGER; constant w1 : IN INTEGER; constant w2 : IN INTEGER; constant a_in0 : IN INTEGER; constant a_in1 : IN INTEGER; constant a_in2 : IN INTEGER) IS
VARIABLE weights : UNSIGNED(23 DOWNTO 0) := TO_UNSIGNED(w2,8) & TO_UNSIGNED(w1,8) & TO_UNSIGNED(w0,8);
VARIABLE a_in : UNSIGNED(23 DOWNTO 0) := TO_UNSIGNED(a_in2,8) & TO_UNSIGNED(a_in1,8) & TO_UNSIGNED(a_in0,8);
BEGIN
clock_sig <= '0';
weights_sig <= weights;
a_in_sig <= a_in;
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
(clock_sig, reset_sig, hard_reset_sig, setup_sig, go_sig, stall_sig) <= TO_UNSIGNED(0,6);
wait for 20 ns;

setup_sig <= '1';
CLOCK_W_DATA_IN(1, 2, 3, 3, 6, 9);
setup_sig <= '0';
CLOCK_W_DATA_IN(4, 5, 6, 2, 5, 8);
setup_sig <= '1'; -- test that setup wont be interrupted
CLOCK_W_DATA_IN(7, 8, 9, 7, 8, 9);
setup_sig <= '0';

--do nothing for a bit
CLOCK;

-- initiate go
go_sig <= '1';
CLOCK;
go_sig <= '0';
CLOCK;
go_sig <= '1'; -- make sure second go signal doesn't interrupt
CLOCK;
go_sig <= '0';
CLOCK;
stall_sig <= '1';
CLOCK;
CLOCK;
stall_sig <= '0';
FOR i IN 7 DOWNTO 0 LOOP
	CLOCK;
END LOOP;
stall_sig <= '1';
CLOCK;
stall_sig <= '0';
FOR i IN 5 DOWNTO 0 LOOP
	CLOCK;
END LOOP;

WAIT;
END PROCESS;

END test;