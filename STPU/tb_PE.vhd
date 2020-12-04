LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY tb_PE IS
END tb_PE;

ARCHITECTURE test OF  tb_PE IS

COMPONENT PE IS
PORT (clock, reset, hard_reset, ld, ld_w : IN STD_LOGIC;
		a_in, w_in, part_in : IN UNSIGNED(7 DOWNTO 0);
		partial_sum, a_out : OUT UNSIGNED(7 DOWNTO 0));
END Component;

SIGNAL res, hard_res, ld, ldw: STD_LOGIC;
SIGNAL a_in, w_in, p_in, p_sum, a_out: UNSIGNED(7 DOWNTO 0);
signal clk: std_logic:='1';
constant period : time := 20 ns;

BEGIN 

DUT: PE PORT MAP(clock => clk, reset => res, hard_reset => hard_res, ld => ld, ld_w => ldw, a_in => a_in, w_in => w_in, part_in => p_in, partial_sum => p_sum, a_out => a_out);

clk<= NOT clk after period WHEN NOW < 630 ns ELSE '0' ;

PROCESS IS

BEGIN

res <= '1';        --nothing loads in here
hard_res <= '1';
ld <= '1';
ldw <= '1';
a_in <= "11111111";
w_in <= "11111111";
p_in <= "11111111";
wait for 15 ns;

res <= '0';        --only W loads
hard_res <= '0';
ld <= '0';
ldw <= '1';
a_in <= "11111111";
w_in <= "11111111";
p_in <= "11111111";
wait for 20 ns;

res <= '0';        --only A and Y loads
hard_res <= '0';
ld <= '1';
ldw <= '0';
a_in <= "11111111";
w_in <= "11111111";
p_in <= "11111111";
wait for 45 ns;

res <= '0';        --5*10 + overflow of 50 = 100
hard_res <= '0';
ld <= '1';
ldw <= '1';
a_in <= "00000101";
w_in <= "00001010";
p_in <= "00110010";
wait for 45 ns;

res <= '0';        --5*10 + overflow of 255 = 255
hard_res <= '0';
ld <= '1';
ldw <= '1';
a_in <= "00000101";
w_in <= "00001010";
p_in <= "11111111";
wait for 45 ns;

res <= '0';        --128*3 + overflow of 0 = 255
hard_res <= '0';
ld <= '1';
ldw <= '1';
a_in <= "10000000";
w_in <= "00000011";
p_in <= "00000000";
wait for 20 ns;

res <= '0';        --128*3 + overflow of 255 = 255
hard_res <= '0';
ld <= '1';
ldw <= '1';
a_in <= "10000000";
w_in <= "00000011";
p_in <= "11111111";
wait for 45 ns;

WAIT;

END PROCESS;

end test; 