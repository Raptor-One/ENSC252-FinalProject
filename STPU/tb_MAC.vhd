 LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY tb_MAC IS
END tb_MAC;

ARCHITECTURE test of tb_MAC IS

COMPONENT MAC IS
	PORT(part_in, a_in, weight_in : IN unsigned(7 DOWNTO 0);
				mac_out : OUT unsigned(7 DOWNTO 0) );
END COMPONENT;
	
SIGNAL Asig, Wsig, Ssig, fsig: unsigned (7 DOWNTO 0);

BEGIN
DUT: MAC
	PORT MAP (a_in=>Asig, weight_in=>Wsig, part_in=>Ssig, maC_out=>fSig);

PROCESS IS
BEGIN 

--112*1+0
Asig <= to_unsigned(112, 8);
Wsig <= to_unsigned(1, 8);
Ssig <= to_unsigned(0, 8);
wait for 20 ns;

--112*3+0
Asig <= to_unsigned(112,8);
Wsig <= to_unsigned(3,8);
Ssig <= to_unsigned(0,8);
wait for 20 ns;

--112*1 +40
Asig <= to_unsigned(112,8);
Wsig <= to_unsigned(1,8);
Ssig <= to_unsigned(40, 8);
wait for 20 ns;

--112*2 +40
Asig <= to_unsigned(112, 8);
Wsig <= to_unsigned(2, 8);
Ssig <= to_unsigned(40, 8);
wait for 20 ns;

WAIT;
END PROCESS;

END test;