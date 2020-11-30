LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.systolic_package.all; 

ENTITY ActivationUnit IS
GENERIC( matrixSize : UNSIGNED := "011" );
PORT( clock, reset, hard_reset, stall, data_start : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0); -- there may be more inputs
		done : out STD_LOGIC;
		row0, row1, row2 : OUT bus_type);
END ActivationUnit;

ARCHITECTURE Behaviour OF ActivationUnit IS
SIGNAL timer : UNSIGNED(2 DOWNTO 0);
TYPE matrix_buffer_type IS ARRAY (0 to 2, 0 to 1) OF UNSIGNED(N-1 DOWNTO 0);
SIGNAL matrix_buffer : matrix_buffer_type;
BEGIN

buf: FOR r IN 0 TO 2 GENERATE
	matrix_buffer(r,0) <= matrix_buffer(r,1) WHEN rising_edge(clock) AND stall = '0';
END GENERATE;

PROCESS(clock)
BEGIN
IF(rising_edge(clock) AND stall = '0') THEN
	matrix_buffer(0,1) <= y_in0;
	matrix_buffer(1,1) <= y_in1;
	matrix_buffer(2,1) <= y_in1;
END IF;
END PROCESS;


PROCESS(clock, reset, hard_reset)
BEGIN
IF(reset = '1' OR hard_reset = '1') THEN
	timer <= (others => '0');
	done <= '0';
ELSIF(rising_edge(clock) AND stall = '0' AND data_start = '1') THEN
	timer <= timer + 1;
	done <= '0';
	
	IF(timer = matrixSize + 2) THEN
		row0 <= (matrix_buffer(0,0), matrix_buffer(0,1), y_in0);
	ELSIF(timer = matrixSize + 3) THEN
		row1 <= (matrix_buffer(1,0), matrix_buffer(1,1), y_in1);
	ELSIF(timer = matrixSize + 4) THEN
		row2 <= (matrix_buffer(2,0), matrix_buffer(2,1), y_in2);
		timer <= matrixSize + 2;
		done <= '1';
	END IF;
	
END IF;

END PROCESS;

END Behaviour;