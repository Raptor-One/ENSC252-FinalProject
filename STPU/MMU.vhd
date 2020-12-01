LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY MMU IS
PORT( clock, reset, hard_reset, ld, ld_w, stall : IN STD_LOGIC;
		a0, a1, a2, w0, w1, w2 : IN UNSIGNED(7 DOWNTO 0);
		y0, y1, y2 : OUT UNSIGNED(7 DOWNTO 0));
END MMU;
