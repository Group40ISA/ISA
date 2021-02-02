LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU IS
	PORT (
		A, B : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		AluCtrl : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		zero : OUT STD_LOGIC;
		result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END ENTITY ALU;

ARCHITECTURE RTL OF ALU IS

	SIGNAL A_sel, B_sel : STD_LOGIC;
	SIGNAL Mux_sel : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL Op1, Op2 : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Add_out, Shift_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL zero1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL set : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Adder_mux_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL B_sel_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Slt_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL set_zero : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	A_sel <= AluCtrl(3);
	B_sel <= AluCtrl(2);

	Mux_sel <= AluCtrl(1 DOWNTO 0);

	zero1 <= (OTHERS => '0');

	set <= (0 => '1', OTHERS => '0');
	set_zero <= (OTHERS => '0');

	B_sel_extended <= (0 => B_sel, OTHERS => '0');

	Slt_ctrl <= Add_out(31) & B_sel;

	WITH A_sel SELECT Op1 <=
		A WHEN '0',
		NOT A WHEN '1',
		(OTHERS => 'U') WHEN OTHERS;

	WITH B_sel SELECT Op2 <=
		B WHEN '0',
		NOT B WHEN '1',
		(OTHERS => 'U') WHEN OTHERS;

	WITH Mux_sel SELECT result <=
		(Op1 AND Op2) WHEN "00",
		Adder_mux_out WHEN "11",
		Shift_out WHEN "10",
		(Op1 XOR Op2) WHEN "01",
		(OTHERS => 'U') WHEN OTHERS;

	Add_out <= STD_LOGIC_VECTOR(signed(Op1) + signed(Op2) + signed(B_sel_extended));
	PROCESS (Add_out, A_sel)--@suppressive
	BEGIN
		IF (Add_out = zero1 OR A_sel = '1') THEN
			zero <= '1';
		ELSE
			zero <= '0';
		END IF;
	END PROCESS;

	WITH Slt_ctrl SELECT Adder_mux_out <=
		Add_out WHEN "00" | "10",
		set WHEN "11",
		set_zero WHEN "01",
		(OTHERS => 'U') WHEN OTHERS;

	Shift_out <= STD_LOGIC_VECTOR(shift_right(signed(Op1), to_integer(unsigned(Op2(4 DOWNTO 0)))));

END ARCHITECTURE RTL;