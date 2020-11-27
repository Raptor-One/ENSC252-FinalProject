LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY ActivationUnit IS
PORT( clock, reset, hard_reset, stall : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0); -- there may be more inputs
		done : out STD_LOGIC;
		row0, row1, row2 : OUT UNSIGNED(7 DOWNTO 0)); -- OUT will use the custom datatype not unsigned
END ActivationUnit;
