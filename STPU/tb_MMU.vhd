LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY tb_MMU IS
END tb_MMU;

ARCHITECTURE test of tb_MMU IS

COMPONENT MMU IS
PORT( clock, reset, hard_reset, ld, ld_w, stall : IN STD_LOGIC;
		a0, a1, a2, w0, w1, w2 : IN UNSIGNED(7 DOWNTO 0);
		y0, y1, y2 : OUT UNSIGNED(7 DOWNTO 0));
END COMPONENT;

SIGNAL clk, reset, hard_reset, ld_sig, ld_W, stall: STD_LOGIC;
SIGNAL a0_sig, a1_sig, a2_sig, w0_sig, w1_sig, w2_sig, y0, y1, y2 : UNSIGNED(7 DOWNTO 0);

BEGIN
DUT: MMU PORT MAP(clock=>clk, reset=>reset, hard_reset=>hard_reset, ld=>ld_sig, ld_w=>ld_w, stall=>stall, a0=>a0_sig, a1=>a1_sig, a2=>a2_sig, w0=>w0_sig, w1=>w1_sig, w2=>w2_sig, y0=>y0, y1=>y1, y2=>y2);


process 

PROCEDURE CLOCK_DATA( constant reset_v : in std_logic; constant hard_reset_v : in std_logic; constant ld : IN std_logic; constant ld_w_sig :  in std_logic; constant stall_sig : in std_logic; constant W0 : IN integer; constant W1 : IN integer; constant W2 : in integer ; constant A0: IN integer; constant A1: IN integer; constant A2: IN integer ) IS
BEGIN
clk <= '0';
reset <= reset_v;
hard_reset <= hard_reset_v;
ld_sig <= ld;
ld_w <= ld_w_sig;
stall<= stall_sig;
w0_sig<= to_unsigned(W0, 8);
w1_sig<= to_unsigned(W1, 8);
w2_sig<= to_unsigned(W2, 8);
a0_sig <= to_unsigned(A0, 8);
a1_sig <= to_unsigned(A1, 8);
a2_sig <= to_unsigned(A2, 8);
wait for 20 ns;
clk <= '1';
wait for 20 ns;
END PROCEDURE;
PROCEDURE CLOCK IS
BEGIN
clk <= '0';
wait for 20 ns;
clk <= '1';
wait for 20 ns;
END PROCEDURE;

begin
-- for reference:
--CLOCK_DATA(reset, hard-reset, ld, ld_w, stall, w0, w1, w2, a0, a1, a2 );
-- setup:
CLOCK_DATA('1', '1', '0', '0', '0', 0, 0, 0, 0, 0, 0);
CLOCK_DATA('0', '0', '0', '1', '0', 1, 2, 3, 0, 0, 0);
CLOCK_DATA('0', '0', '0', '1', '0', 4, 5, 6, 0, 0, 0);
CLOCK_DATA('0', '0', '0', '1', '0', 7, 8, 9, 0, 0, 0);
CLOCK_DATA('0', '0', '0', '0', '0', 0, 0, 0, 0, 0, 0);

--going to compute  mode:
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 3, 0, 0);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 2, 6, 0);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 7, 5, 9);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 8, 8);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 0, 9);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 0, 0);
CLOCK;
CLOCK;
CLOCK;

--going to compute mode with stalls:
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 3, 0, 0);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 2, 6, 0);
CLOCK_DATA('0', '0', '1', '0', '1', 0, 0, 0, 2, 6, 0);--stall
CLOCK_DATA('0', '0', '1', '0', '1', 0, 0, 0, 2, 6, 0);--stall
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 7, 5, 9);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 8, 8);
CLOCK_DATA('0', '0', '1', '0', '1', 0, 0, 0, 0, 8, 8);--stall
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 0, 9);
CLOCK_DATA('0', '0', '1', '0', '0', 0, 0, 0, 0, 0, 0);
CLOCK;
stall <= '1'; -- check if outptus are held on stall
CLOCK;
CLOCK;
CLOCK;
stall <= '0';
CLOCK;
CLOCK;


wait;
end process;

END test;
