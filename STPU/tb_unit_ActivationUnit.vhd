LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE work.systolic_package.all; 

ENTITY tb_unit_ActivationUnit IS
END tb_unit_ActivationUnit;

ARCHITECTURE test of tb_unit_ActivationUnit IS
COMPONENT ActivationUnit IS
PORT( clock, reset, hard_reset, stall, calc_active : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		done : out STD_LOGIC;
		row0, row1, row2 : OUT bus_type);
END COMPONENT;

SIGNAL clock_sig, reset_sig, hard_reset_sig, stall_sig, data_start_sig, done_sig: STD_LOGIC;
SIGNAL y_in0_sig, y_in1_sig, y_in2_sig : UNSIGNED(N-1 DOWNTO 0);
SIGNAL row0_sig, row1_sig, row2_sig : bus_type;

BEGIN
DUT : ActivationUnit
PORT MAP(clock => clock_sig, reset => reset_sig, hard_reset => hard_reset_sig, stall => stall_sig, calc_active => data_start_sig, 
			y_in0 => y_in0_sig, y_in1 => y_in1_sig, y_in2 => y_in2_sig, row0 => row0_sig, row1 => row1_sig, row2 => row2_sig, done => done_sig);

PROCESS IS
--procedure that sets values of y0-y2 and does a clock cycle
PROCEDURE CLOCK_W_DATA(constant y0 : IN INTEGER; constant y1 : IN INTEGER; constant y2 : IN INTEGER) IS
BEGIN
clock_sig <= '0';
y_in0_sig <= TO_UNSIGNED(y0,8);
y_in1_sig <= TO_UNSIGNED(y1,8);
y_in2_sig <= TO_UNSIGNED(y2,8);
wait for 20 ns;
clock_sig <= '1';
wait for 20 ns;
END PROCEDURE;
BEGIN
	-- sets / reset
	(clock_sig, stall_sig, data_start_sig, hard_reset_sig, reset_sig) <= TO_UNSIGNED(1,5);
	y_in0_sig <= TO_UNSIGNED(0,8);
	y_in1_sig <= TO_UNSIGNED(0,8);
	y_in2_sig <= TO_UNSIGNED(0,8);
	wait for 20 ns;
	reset_sig <= '0';
	
	--empty clock cycle
	CLOCK_W_DATA(0,0,0);
	
	--test regular case of ouputting data from pipeline
	data_start_sig <= '1';
	-- simulate MMU calculating
	CLOCK_W_DATA(0,0,0);
	CLOCK_W_DATA(0,0,0);
	CLOCK_W_DATA(0,0,0);
	CLOCK_W_DATA(1,0,0);
	CLOCK_W_DATA(2,4,0);
	CLOCK_W_DATA(3,5,7);
	CLOCK_W_DATA(9,6,8);
	CLOCK_W_DATA(8,6,9);
	CLOCK_W_DATA(7,5,3);
	CLOCK_W_DATA(0,4,2);
	CLOCK_W_DATA(0,0,1);
	
	--test reset (soft)
	data_start_sig <= '0';
	reset_sig <= '1';
	wait for 20 ns;
	reset_sig <= '0';
	
	--test case with a stall
	data_start_sig <= '1';
	-- simulate MMU calculating
	CLOCK_W_DATA(0,0,0);
	CLOCK_W_DATA(0,0,0);
	stall_sig <= '1'; -- test stall before MMU finished calculaing
	CLOCK_W_DATA(99,99,99); -- garbage data that should be ignored
	stall_sig <= '0'; -- continue
	CLOCK_W_DATA(0,0,0);
	CLOCK_W_DATA(1,0,0);
	CLOCK_W_DATA(3,2,0);
	CLOCK_W_DATA(5,4,11);
	stall_sig <= '1'; -- test stall during MMU output
	CLOCK_W_DATA(99,99,99); -- garbage data that should be ignored
	CLOCK_W_DATA(99,99,99); 
	stall_sig <= '0'; -- continue
	CLOCK_W_DATA(0,6,13);
	CLOCK_W_DATA(0,0,15);
	stall_sig <= '1'; -- test after done (done signal should be kept raised)
	CLOCK_W_DATA(99,99,99); -- garbage data that should be ignored
	stall_sig <= '0'; -- continue
	
	--test reset (hard)
	data_start_sig <= '0';
	hard_reset_sig <= '1';
	wait for 20 ns;
	hard_reset_sig <= '0';
	
	WAIT; --process is done, wait for completion
END PROCESS;

END test;

