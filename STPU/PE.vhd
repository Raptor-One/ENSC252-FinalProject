LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY PE IS
PORT (clock, reset, hard_reset, ld, ld_w : IN STD_LOGIC;
		a_in, w_in, part_in : IN UNSIGNED(7 DOWNTO 0);
		partial_sum, a_out : OUT UNSIGNED(7 DOWNTO 0));
END PE;

ARCHITECTURE STRUCTURE OF PE IS 

COMPONENT LoadRegister IS
	PORT (clock, ld, reset : IN STD_LOGIC;
			D : IN UNSIGNED(7 DOWNTO 0);
			Q : OUT UNSIGNED(7 DOWNTO 0));
END LoadRegister;

COMPONENT MAC IS 
	PORT (