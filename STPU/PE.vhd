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
	PORT (clock, ld, reset: IN STD_LOGIC;
			D : IN UNSIGNED(7 DOWNTO 0);
			Q : OUT UNSIGNED(7 DOWNTO 0));
END COMPONENT;

COMPONENT MAC IS 
	PORT (part_in, a_in, weight_in : IN unsigned(7 DOWNTO 0);
			mac_out : OUT unsigned(7 DOWNTO 0));
END COMPONENT;

SIGNAL MAC_IN, Y_IN, A_O, PS: unsigned(7 DOWNTO 0);
SIGNAL s_res, h_res, res_or: STD_LOGIC;

BEGIN

	s_res <= reset;
	h_res <= hard_reset;
	res_or <= (s_res OR h_res);
	
	W: LoadRegister PORT MAP(clock => clock, ld => ld_w, reset => h_res, D => w_in, Q=> MAC_IN);
	P_Sum: MAC PORT MAP(part_in => part_in, a_in => a_in, weight_in => MAC_IN, mac_out=> Y_IN);	
	A: LoadRegister PORT MAP(clock => clock, ld => ld, reset => res_or, D => a_in, Q => A_O);
	Y: LoadRegister PORT MAP(clock => clock, ld => ld, reset => res_or, D => Y_IN, Q=> PS);
		
	a_out <= A_O;
	partial_sum <= PS;

END STRUCTURE;