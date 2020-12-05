LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY MMU IS
PORT( clock, reset, hard_reset, ld, ld_w, stall : IN STD_LOGIC;
		a0, a1, a2, w0, w1, w2 : IN UNSIGNED(7 DOWNTO 0);
		y0, y1, y2 : OUT UNSIGNED(7 DOWNTO 0));
END MMU;

ARCHITECTURE STRUCTURE OF MMU IS

COMPONENT PE IS
PORT (clock, reset, hard_reset, ld, ld_w : IN STD_LOGIC;
		a_in, w_in, part_in : IN UNSIGNED(7 DOWNTO 0);
		partial_sum, a_out : OUT UNSIGNED(7 DOWNTO 0));
END COMPONENT;

SIGNAL GND: UNSIGNED(7 DOWNTO 0):="00000000";
SIGNAL PSUM_11, PSUM_21, PSUM_12, PSUM_22, PSUM_13, PSUM_23, AOUT_11, AOUT_12, AOUT_21, AOUT_22, AOUT_31, AOUT_32: UNSIGNED(7 DOWNTO 0);

signal ld_c1, ld_c2, ld_c3, ld_sig: std_logic := '0';
Signal ps : std_logic_vector(1 downto 0):= "00"; --for present state (total 4 states) 		//  initalize here as idle
--Signal cm : std_logic:='0';		  --for current mode of operation	// initialized 0 for init mode

BEGIN 

ld_sig <= ld AND NOT stall;

PE_11: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c1, a_in => a0, w_in => w0, part_in => GND, partial_sum => PSUM_11, a_out => AOUT_11);
PE_12: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c2, a_in => AOUT_11, w_in => w0, part_in => GND, partial_sum => PSUM_12, a_out => AOUT_12);
PE_13: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c3, a_in => AOUT_12, w_in => w0, part_in => GND, partial_sum => PSUM_13, a_out => open);
PE_21: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c1, a_in => a1, w_in => w1, part_in => PSUM_11, partial_sum => PSUM_21, a_out => AOUT_21);
PE_22: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c2, a_in => AOUT_21, w_in => w1, part_in => PSUM_12, partial_sum => PSUM_22, a_out => AOUT_22);
PE_23: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c3, a_in => AOUT_22, w_in => w1, part_in => PSUM_13, partial_sum => PSUM_23, a_out => open);
PE_31: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c1, a_in => a2, w_in => w2, part_in => PSUM_21, partial_sum => y0, a_out => AOUT_31);
PE_32: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c2, a_in => AOUT_31, w_in => w2, part_in => PSUM_22, partial_sum => y1, a_out => AOUT_32);
PE_33: PE PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => ld_sig, ld_w => ld_c3, a_in => AOUT_32, w_in => w2, part_in => PSUM_23, partial_sum => y2, a_out => open);


PROCESS(clock, hard_reset, reset) 
BEGIN
	IF(hard_reset = '1' or reset = '1') then 
		ps <= "00";
	elsif(rising_edge(clock)) then		-- checking for rising edge of clock
		if(ld = '0' and ld_w = '1' and ps = "00") then		--checking for init mode
			ps<="01";	-- next state basically
		end if;
		if( ps = "01" and ld_w = '1') then 			--load_col2
			
			ps<="10";		-- next state basicalyy
		elsif(ps = "10" and ld_w = '1') then 			--load_col3
			
			ps<="00";  -- next state basically	
		elsif(ps = "11") then
			ps<="00";		--  back to idle state.
		end if;
		if(ld = '1' and ld_w = '0')	then	-- going to compute mode:
				ps<="00";
		end if;
	end if;
	
END PROCESS;

PROCESS(ps, ld_w)
BEGIN
ld_c1<= ld_w;
ld_c2<='0';
ld_c3<='0';
if( ps = "01") then
	ld_c1<='0';
	ld_c2<='1';
	ld_c3<='0';
elsif(ps = "10") then
	ld_c1<='0';
	ld_c2<='0';
	ld_c3<='1';
end if;
END PROCESS;

END STRUCTURE;