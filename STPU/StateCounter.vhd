LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY StateCounter IS
GENERIC( maxState : UNSIGNED := "11"; wrapBackState : UNSIGNED := "00" );
PORT( clock, reset, enable : IN STD_LOGIC;
		state : out UNSIGNED(maxState'length-1 DOWNTO 0));
END StateCounter;

ARCHITECTURE Behaviour OF StateCounter IS
SIGNAL current_state : UNSIGNED(maxState'length-1 DOWNTO 0) := (others => '0');
BEGIN

state <= current_state;

PROCESS(clock, reset)
BEGIN
IF(reset = '1') THEN
	current_state <= (others => '0'); -- reset sets to 0
ELSIF(rising_edge(clock) AND enable = '1') THEN -- only incremend when enabled
	current_state <= current_state + 1;
	IF(current_state = maxState) THEN
		current_state <= wrapBackState; -- set counter back to wrapBackState once maxState reached
	END IF;
END IF;

END PROCESS;

END Behaviour;