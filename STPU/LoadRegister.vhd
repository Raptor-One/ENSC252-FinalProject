LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY LoadRegister IS
PORT( clock, ld, reset: IN STD_LOGIC;
		D : IN UNSIGNED(7 DOWNTO 0);
		Q : OUT UNSIGNED(7 DOWNTO 0));
END LoadRegister;


ARCHITECTURE BEHAVIOUR of LoadRegister IS
	SIGNAL temp : UNSIGNED(7 DOWNTO 0) := "00000000";
	
BEGIN 
	  
	PROCESS(clock, reset)
	BEGIN
	IF(reset = '1') then
		temp <= (others=>'0'); 
	ELSIF (rising_edge(clock) AND ld = '1') then
		temp <= D;
	END IF;
	
	END PROCESS;
	
	Q <= temp;
	
END BEHAVIOUR;
