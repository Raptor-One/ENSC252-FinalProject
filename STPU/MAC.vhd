LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;


Entity MAC is
	PORT(part_in, a_in, weight_in : IN unsigned(7 DOWNTO 0);
				mac_out : OUT unsigned(7 DOWNTO 0) );
End Entity;

ARCHITECTURE structure of MAC is 
	signal temp1,  temp3 : unsigned(15 downto 0);
	
begin
		temp1<= a_in*weight_in;

		temp3 <= (others=>'1') when (signed(temp1) > 254) else
				 temp1+part_in;
		
		mac_out<="11111111" when (signed(temp3) > 254) else
				   resize(temp3, 8);
		
END Architecture;