-- VHDL Entity HAVOC.FPmul.symbol
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY FPmul IS
	PORT (
		FP_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		FP_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		clk : IN STD_LOGIC;
		FP_Z : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);

	-- Declarations

END FPmul;

--
-- VHDL Architecture HAVOC.FPmul.pipeline
--
-- Created by
-- Guillermo Marcus, gmarcus@ieee.org
-- using Mentor Graphics FPGA Advantage tools.
--
-- Visit "http://fpga.mty.itesm.mx" for more info.
--
-- Copyright 2003-2004. V1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ARCHITECTURE pipeline OF FPmul IS

	-- Architecture declarations

	-- Internal signal declarations
	SIGNAL A_EXP : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL A_SIG : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL B_EXP : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL B_SIG : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EXP_in, EXP_in_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL EXP_neg : STD_LOGIC;
	SIGNAL EXP_neg_stage2, EXP_neg_stage2_reg : STD_LOGIC;
	SIGNAL EXP_out_round : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL EXP_pos : STD_LOGIC;
	SIGNAL EXP_pos_stage2, EXP_pos_stage2_reg : STD_LOGIC;
	SIGNAL SIGN_out : STD_LOGIC;
	SIGNAL SIGN_out_stage1 : STD_LOGIC;
	SIGNAL SIGN_out_stage2, SIGN_out_stage2_reg : STD_LOGIC;
	SIGNAL SIG_in, SIG_in_reg : STD_LOGIC_VECTOR(27 DOWNTO 0);
	SIGNAL SIG_out_round : STD_LOGIC_VECTOR(27 DOWNTO 0);
	SIGNAL isINF_stage1 : STD_LOGIC;
	SIGNAL isINF_stage2, isINF_stage2_reg : STD_LOGIC;
	SIGNAL isINF_tab : STD_LOGIC;
	SIGNAL isNaN : STD_LOGIC;
	SIGNAL isNaN_stage1 : STD_LOGIC;
	SIGNAL isNaN_stage2, isNaN_stage2_reg : STD_LOGIC;
	SIGNAL isZ_tab : STD_LOGIC;
	SIGNAL isZ_tab_stage1 : STD_LOGIC;
	SIGNAL isZ_tab_stage2, isZ_tab_stage2_reg : STD_LOGIC;
	SIGNAL Internal_FP_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Internal_FP_B : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL tmp_FP_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL tmp_FP_B : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Component Declarations
	COMPONENT FPmul_stage1
		PORT (
			FP_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			FP_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk : IN STD_LOGIC;
			A_EXP : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			A_SIG : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			B_EXP : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			B_SIG : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGN_out_stage1 : OUT STD_LOGIC;
			isINF_stage1 : OUT STD_LOGIC;
			isNaN_stage1 : OUT STD_LOGIC;
			isZ_tab_stage1 : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT FPmul_stage2
		PORT (
			A_EXP : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			A_SIG : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			B_EXP : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			B_SIG : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGN_out_stage1 : IN STD_LOGIC;
			clk : IN STD_LOGIC;
			isINF_stage1 : IN STD_LOGIC;
			isNaN_stage1 : IN STD_LOGIC;
			isZ_tab_stage1 : IN STD_LOGIC;
			EXP_in : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			EXP_neg_stage2 : OUT STD_LOGIC;
			EXP_pos_stage2 : OUT STD_LOGIC;
			SIGN_out_stage2 : OUT STD_LOGIC;
			SIG_in : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
			isINF_stage2 : OUT STD_LOGIC;
			isNaN_stage2 : OUT STD_LOGIC;
			isZ_tab_stage2 : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT FPmul_stage3
		PORT (
			EXP_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			EXP_neg_stage2 : IN STD_LOGIC;
			EXP_pos_stage2 : IN STD_LOGIC;
			SIGN_out_stage2 : IN STD_LOGIC;
			SIG_in : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
			clk : IN STD_LOGIC;
			isINF_stage2 : IN STD_LOGIC;
			isNaN_stage2 : IN STD_LOGIC;
			isZ_tab_stage2 : IN STD_LOGIC;
			EXP_neg : OUT STD_LOGIC;
			EXP_out_round : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			EXP_pos : OUT STD_LOGIC;
			SIGN_out : OUT STD_LOGIC;
			SIG_out_round : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
			isINF_tab : OUT STD_LOGIC;
			isNaN : OUT STD_LOGIC;
			isZ_tab : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT FPmul_stage4
		PORT (
			EXP_neg : IN STD_LOGIC;
			EXP_out_round : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			EXP_pos : IN STD_LOGIC;
			SIGN_out : IN STD_LOGIC;
			SIG_out_round : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
			clk : IN STD_LOGIC;
			isINF_tab : IN STD_LOGIC;
			isNaN : IN STD_LOGIC;
			isZ_tab : IN STD_LOGIC;
			FP_Z : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT shift
		GENERIC (levelPipe : INTEGER := 5);
		PORT (
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			D : IN STD_LOGIC;
			Q : OUT STD_LOGIC
		);
	END COMPONENT shift;

	-- Optional embedded configurations
	-- pragma synthesis_off
	FOR ALL : FPmul_stage1 USE ENTITY work.FPmul_stage1;
	FOR ALL : FPmul_stage2 USE ENTITY work.FPmul_stage2;
	FOR ALL : FPmul_stage3 USE ENTITY work.FPmul_stage3;
	FOR ALL : FPmul_stage4 USE ENTITY work.FPmul_stage4;
	-- pragma synthesis_on

BEGIN

	INPUT_REGISTER : PROCESS (clk)
	BEGIN
		IF (clk'event AND clk = '1') THEN
			tmp_FP_A <= FP_A;
			tmp_FP_B <= FP_B;
		END IF;
	END PROCESS;
	Internal_FP_A <= tmp_FP_A;
	Internal_FP_B <= tmp_FP_B;

	stage_2_REGISTER : PROCESS (clk)
	BEGIN
		IF (clk'event AND clk = '1') THEN
			EXP_in_reg <= EXP_in;
			EXP_neg_stage2_reg <= EXP_neg_stage2;
			EXP_pos_stage2_reg <= EXP_pos_stage2;
			SIGN_out_stage2_reg <= SIGN_out_stage2;
			SIG_in_reg <= SIG_in;
			isINF_stage2_reg <= isINF_stage2;
			isNaN_stage2_reg <= isNaN_stage2;
			isZ_tab_stage2_reg <= isZ_tab_stage2;
		END IF;
	END PROCESS;

	-- Instance port mappings.
	I1 : FPmul_stage1
	PORT MAP(
		FP_A => Internal_FP_A,
		FP_B => Internal_FP_B,
		clk => clk,
		A_EXP => A_EXP,
		A_SIG => A_SIG,
		B_EXP => B_EXP,
		B_SIG => B_SIG,
		SIGN_out_stage1 => SIGN_out_stage1,
		isINF_stage1 => isINF_stage1,
		isNaN_stage1 => isNaN_stage1,
		isZ_tab_stage1 => isZ_tab_stage1
	);
	I2 : FPmul_stage2
	PORT MAP(
		A_EXP => A_EXP,
		A_SIG => A_SIG,
		B_EXP => B_EXP,
		B_SIG => B_SIG,
		SIGN_out_stage1 => SIGN_out_stage1,
		clk => clk,
		isINF_stage1 => isINF_stage1,
		isNaN_stage1 => isNaN_stage1,
		isZ_tab_stage1 => isZ_tab_stage1,
		EXP_in => EXP_in,
		EXP_neg_stage2 => EXP_neg_stage2,
		EXP_pos_stage2 => EXP_pos_stage2,
		SIGN_out_stage2 => SIGN_out_stage2,
		SIG_in => SIG_in,
		isINF_stage2 => isINF_stage2,
		isNaN_stage2 => isNaN_stage2,
		isZ_tab_stage2 => isZ_tab_stage2
	);
	I3 : FPmul_stage3
	PORT MAP(
		EXP_in => EXP_in_reg3,
		EXP_neg_stage2 => EXP_neg_stage2_reg,
		EXP_pos_stage2 => EXP_pos_stage2_reg,
		SIGN_out_stage2 => SIGN_out_stage2_reg,
		SIG_in => SIG_in_reg,
		clk => clk,
		isINF_stage2 => isINF_stage2_reg,
		isNaN_stage2 => isNaN_stage2_reg,
		isZ_tab_stage2 => isZ_tab_stage2_reg,
		EXP_neg => EXP_neg,
		EXP_out_round => EXP_out_round,
		EXP_pos => EXP_pos,
		SIGN_out => SIGN_out,
		SIG_out_round => SIG_out_round,
		isINF_tab => isINF_tab,
		isNaN => isNaN,
		isZ_tab => isZ_tab
	);
	I4 : FPmul_stage4
	PORT MAP(
		EXP_neg => EXP_neg,
		EXP_out_round => EXP_out_round,
		EXP_pos => EXP_pos,
		SIGN_out => SIGN_out,
		SIG_out_round => SIG_out_round,
		clk => clk,
		isINF_tab => isINF_tab,
		isNaN => isNaN,
		isZ_tab => isZ_tab,
		FP_Z => FP_Z
	);

END pipeline;