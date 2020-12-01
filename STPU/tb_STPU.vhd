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

PROCEDURE CLOCK_W_DATA_IN(constant weights : IN UNSIGNED(23 DOWNTO 0); constant a_in : IN UNSIGNED(23 DOWNTO 0)) IS
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
CLOCK_W_DATA_IN( TO_UNSIGNED(1,8) & TO_UNSIGNED(2,8) & TO_UNSIGNED(3,8), TO_UNSIGNED(0,24));
setup_sig <= '0';
CLOCK_W_DATA_IN( TO_UNSIGNED(4,8) & TO_UNSIGNED(5,8) & TO_UNSIGNED(6,8), TO_UNSIGNED(0,24));
setup_sig <= '1'; -- test that setup wont be interrupted
CLOCK_W_DATA_IN( TO_UNSIGNED(7,8) & TO_UNSIGNED(8,8) & TO_UNSIGNED(9,8), TO_UNSIGNED(0,24));
setup_sig <= '0';

--do nothing for a bit
CLOCK;

go_sig <= '1';
CLOCK;
go_sig <= '0';
CLOCK;
go_sig <= '1';
CLOCK;
go_sig <= '0';
CLOCK;
stall_sig <= '1';
CLOCK;
CLOCK;
stall_sig <= '0';
FOR i IN 5 DOWNTO 0 LOOP
	CLOCK;
END LOOP;

WAIT;
END PROCESS;

END test;