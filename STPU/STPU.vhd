LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE work.systolic_package.all; 

ENTITY STPU IS
PORT( clock, reset, hard_reset, setup, go, stall: IN STD_LOGIC;
		weights, a_in : IN UNSIGNED(23 DOWNTO 0);
		done : out STD_LOGIC;
		y0, y1, y2 : OUT bus_type);
END STPU;

ARCHITECTURE Structure OF STPU IS

COMPONENT StateCounter IS
GENERIC( maxState : UNSIGNED := "11"; wrapBackState : UNSIGNED := "00" );
PORT( clock, reset, enable : IN STD_LOGIC;
		state : out UNSIGNED(maxState'length-1 DOWNTO 0));
END COMPONENT;

COMPONENT MMU IS
PORT( clock, reset, hard_reset, ld, ld_w, stall : IN STD_LOGIC;
		a0, a1, a2, w0, w1, w2 : IN UNSIGNED(7 DOWNTO 0);
		y0, y1, y2 : OUT UNSIGNED(7 DOWNTO 0));
END COMPONENT;

COMPONENT WRAM IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ActivationUnit IS
GENERIC( matrixSize : UNSIGNED := "011" );
PORT( clock, reset, hard_reset, stall, data_start : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		done : out STD_LOGIC;
		row0, row1, row2 : OUT bus_type);
END COMPONENT;

SIGNAL setup_sc_enable, go_sc_enable, go_sc_reset, activation_unit_done : STD_LOGIC;
SIGNAL setupState : UNSIGNED(1 DOWNTO 0);
SIGNAL goState : UNSIGNED(2 DOWNTO 0) ;
SIGNAL wram_addr, setup_uram_addr, go_uram0_addr, go_uram1_addr, go_uram2_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL uram_read, wram_write, uram_write, wram_clr, uram_clr, ac_data_start : STD_LOGIC;
SIGNAl w_data_in : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL u0_data_in, u1_data_in, u2_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL mmu_ld, mmu_ld_w : STD_LOGIC;
BEGIN

wr : WRAM PORT MAP(aclr => open, address => wram_addr, clock => clock, data => w_data_in, rden => '1', wren => wram_write, q => open);

--ac : ActivationUnit PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, stall => stall, data_start => ac_data_start,
--									  y_in0 => open, y_in1 => open, y_in2 => open, done => activation_unit_done, row0 => y0, row1 => y1, row2 => y2);

done <= activation_unit_done;

-- setup logic ====================================================
setup_sc_enable <= (setup AND NOT setupState(0) AND NOT setupState (1)) OR (setupState(1) OR setupState(0));
setup_sc : StateCounter GENERIC MAP(maxState => "10", wrapBackState => "00")
PORT MAP(clock => clock, reset => hard_reset, enable => setup_sc_enable, state => setupState);

w_data_in <= STD_LOGIC_VECTOR(weights);
wram_addr <= STD_LOGIC_VECTOR(setupState OR goState(1 DOWNTO 0)); -- setup & go
wram_write <= setupState(1) OR setupState(0) OR setup;

u0_data_in <= STD_LOGIC_VECTOR(a_in(23 DOWNTO 16));
u1_data_in <= STD_LOGIC_VECTOR(a_in(15 DOWNTO 8));
u2_data_in <= STD_LOGIC_VECTOR(a_in(7 DOWNTO 0));
setup_uram_addr <= STD_LOGIC_VECTOR(setupState);
uram_write <= setupState(1) OR setupState(0) OR setup;

-- go logic ====================================================
go_sc_enable <= ((go AND NOT goState(0) AND NOT goState(1) AND NOT goState(2)) OR (goState(2) OR goState(1) OR goState(0))) AND NOT stall;
go_sc_reset <= reset OR hard_reset OR activation_unit_done; -- STPU only done of first result if computing only 1 matrix
go_sc : StateCounter GENERIC MAP(maxState => "101", wrapBackState => "011")
PORT MAP(clock => clock, reset => go_sc_reset, enable => go_sc_enable, state => goState);
ac_data_start <= '1' WHEN goState > "010" ELSE '0';

mmu_ld_w <= '1' WHEN (goState > "000" AND goState <= "010") OR go = '1' ELSE '0';
mmu_ld <= goState(1) OR goState(0) OR go;

PROCESS(goState)
BEGIN
go_uram0_addr <= "11";
go_uram1_addr <= "11";
go_uram2_addr <= "11";
IF(goState = "001") THEN
	go_uram0_addr <= "00";
ELSIF(goState = "010") THEN
	go_uram0_addr <= "01";
	go_uram1_addr <= "00";
ELSIF(goState = "011") THEN
	go_uram0_addr <= "10";
	go_uram1_addr <= "01";
	go_uram2_addr <= "00";
ELSIF(goState = "100") THEN
	go_uram0_addr <= "00";
	go_uram1_addr <= "10";
	go_uram2_addr <= "01";
ELSIF(goState = "101") THEN
	go_uram0_addr <= "01";
	go_uram1_addr <= "00";
	go_uram2_addr <= "10";
END IF;
	
END PROCESS;

END Structure;
