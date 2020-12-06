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

COMPONENT URAM IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ActivationUnit IS
GENERIC( matrixSize : UNSIGNED := "011" );
PORT( clock, reset, hard_reset, stall, data_start : IN STD_LOGIC;
		y_in0, y_in1, y_in2 : IN UNSIGNED(7 DOWNTO 0);
		done : out STD_LOGIC;
		row0, row1, row2 : OUT bus_type);
END COMPONENT;

SIGNAL setup_sc_enable, go_sc_enable, go_sc_reset, activation_unit_done, uram_clear : STD_LOGIC;
SIGNAL setupState : UNSIGNED(1 DOWNTO 0);
SIGNAL goState : UNSIGNED(2 DOWNTO 0) ;
SIGNAL wram_addr, setup_uram_addr, go_uram0_addr, go_uram1_addr, go_uram2_addr, uram0_addr, uram1_addr, uram2_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL uram_clock, wram_write, uram_write, wram_clr, uram_clr, ac_data_start : STD_LOGIC;
SIGNAl w_data_in : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL u0_data_in, u1_data_in, u2_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL mmu_ld, mmu_ld_w : STD_LOGIC;
SIGNAL mmu_a0, mmu_a1, mmu_a2, mmu_w0, mmu_w1, mmu_w2, mmu_y0, mmu_y1, mmu_y2 : UNSIGNED(7 DOWNTO 0);
BEGIN

wr : WRAM PORT MAP(aclr => hard_reset, address => wram_addr, clock => clock, data => w_data_in, rden => '1', wren => wram_write, 
						 UNSIGNED(q(23 DOWNTo 16)) => mmu_w2, UNSIGNED(q(15 DOWNTo 8)) => mmu_w1, UNSIGNED(q(7 DOWNTo 0)) => mmu_w0);
uram_clear <= hard_reset OR reset;
ur0 : URAM PORT MAP(aclr => uram_clear, address => uram0_addr, clock => uram_clock, data => u0_data_in, rden => '1', wren => uram_write, UNSIGNED(q) => mmu_a0);
ur1 : URAM PORT MAP(aclr => uram_clear, address => uram1_addr, clock => uram_clock, data => u1_data_in, rden => '1', wren => uram_write, UNSIGNED(q) => mmu_a1);
ur2 : URAM PORT MAP(aclr => uram_clear, address => uram2_addr, clock => uram_clock, data => u2_data_in, rden => '1', wren => uram_write, UNSIGNED(q) => mmu_a2);

mmu_comp : MMU PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, ld => mmu_ld, ld_w => mmu_ld_w, stall => stall,
						 a0 => mmu_a0, a1 => mmu_a1, a2 => mmu_a2, w0 => mmu_w0, w1 => mmu_w1, w2 => mmu_w2, y0 => mmu_y0, y1 => mmu_y1, y2 => mmu_y2);

ac : ActivationUnit PORT MAP(clock => clock, reset => reset, hard_reset => hard_reset, stall => stall, data_start => ac_data_start,
									  y_in0 => mmu_y0, y_in1 => mmu_y1, y_in2 => mmu_y2, done => activation_unit_done, row0 => y0, row1 => y1, row2 => y2);

done <= activation_unit_done;

-- setup logic ====================================================
setup_sc_enable <= '1' WHEN (setup = '1' AND setupState = "00") oR setupState /= "00" ELSE '0';
--setup_sc_enable <= (setup AND NOT setupState(0) AND NOT setupState (1)) OR (setupState(1) OR setupState(0));
setup_sc : StateCounter GENERIC MAP(maxState => "10", wrapBackState => "00")
PORT MAP(clock => clock, reset => hard_reset, enable => setup_sc_enable, state => setupState);

w_data_in <= STD_LOGIC_VECTOR(weights);
wram_write <= setupState(1) OR setupState(0) OR setup;

-- setup & go TODO: ADD STALL LOGIc
PROCESS(setupState, goState, go)
BEGIN
wram_addr <= STD_LOGIC_VECTOR(setupState);
IF(go = '1' and goState = "000") THEN
	wram_addr <= "01";
ELSIF( goState > "000" ) THEN
	wram_addr <= STD_LOGIC_VECTOR(goState(1 DOWNTO 0) + 1);
END IF;
END PROCESS;

u0_data_in <= STD_LOGIC_VECTOR(a_in(7 DOWNTO 0));
u1_data_in <= STD_LOGIC_VECTOR(a_in(15 DOWNTO 8));
u2_data_in <= STD_LOGIC_VECTOR(a_in(23 DOWNTO 16));
setup_uram_addr <= STD_LOGIC_VECTOR(setupState);
uram_write <= setupState(1) OR setupState(0) OR setup;

-- go logic ====================================================
go_sc_enable <= ((go AND NOT goState(0) AND NOT goState(1) AND NOT goState(2)) OR (goState(2) OR goState(1) OR goState(0))) AND NOT stall;
go_sc_reset <= reset OR hard_reset OR activation_unit_done; -- STPU only done of first result if computing only 1 matrix
go_sc : StateCounter GENERIC MAP(maxState => "110", wrapBackState => "100")
PORT MAP(clock => clock, reset => go_sc_reset, enable => go_sc_enable, state => goState);
ac_data_start <= '1' WHEN goState > "011" ELSE '0';

mmu_ld_w <= '1' WHEN (goState > "000" AND goState <= "011") ELSE '0';
mmu_ld <= '1' WHEN (goState > "011")ELSE '0';

PROCESS(goState)
BEGIN
go_uram0_addr <= "11";
go_uram1_addr <= "11";
go_uram2_addr <= "11";
IF(goState = "010") THEN
	go_uram0_addr <= "00";
ELSIF(goState = "011") THEN
	go_uram0_addr <= "01";
	go_uram1_addr <= "00";
ELSIF(goState = "100") THEN
	go_uram0_addr <= "10";
	go_uram1_addr <= "01";
	go_uram2_addr <= "00";
ELSIF(goState = "101") THEN
	go_uram0_addr <= "00";
	go_uram1_addr <= "10";
	go_uram2_addr <= "01";
ELSIF(goState = "110") THEN
	go_uram0_addr <= "01";
	go_uram1_addr <= "00";
	go_uram2_addr <= "10";
END IF;
	
END PROCESS;

uram_clock <= clock WHEN stall = '0' ELSE '0';

uram0_addr <= setup_uram_addr WHEN setupState /= "00" OR setup = '1' ELSE go_uram0_addr;
uram1_addr <= setup_uram_addr WHEN setupState /= "00" OR setup = '1' ELSE go_uram1_addr;
uram2_addr <= setup_uram_addr WHEN setupState /= "00" OR setup = '1' ELSE go_uram2_addr;

END Structure;
