library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_ALU1 is
end entity test_ALU1;

architecture RTL of test_ALU1 is
	component Imm_plus_ALU
		port(
			A, B    : in  std_logic_vector(31 downto 0);
			AluCtrl : in  std_logic_vector(3 downto 0);
			instr   : in  std_logic_vector(31 downto 0);
			Mux_sel : in  std_logic;
			zero    : out std_logic;
			result  : out std_logic_vector(31 downto 0)
		);
	end component Imm_plus_ALU;


	signal A, B : std_logic_vector(31 downto 0);
	signal AluCtrl : std_logic_vector(3 downto 0);
	signal zero : std_logic;
	signal result : std_logic_vector(31 downto 0);
	signal instr : std_logic_vector(31 downto 0);
	signal Mux_sel : std_logic;
	
begin
	
	ALU_IMM1: Imm_plus_ALU port map(
		A       => A,
		B       => B,
		AluCtrl => AluCtrl,
		instr   => instr,
		Mux_sel => Mux_sel,
		zero    => zero,
		result  => result
	);
	
	
	P1: process
	begin
		A <= std_logic_vector(to_signed(0,32));
		B <= std_logic_vector(to_signed(-8,32));
		instr  <= "11111100000001011000111011100011";
		Mux_sel  <= '1';
		AluCtrl <= "0111";
		wait for 10 ns;
		A <= std_logic_vector(to_signed(9,32));
		instr  <= "00000000000101001111010010010011";
		Mux_sel  <= '1';
		AluCtrl <= "0000";
		wait for 10 ns;
		A <= std_logic_vector(to_signed(128,32));
		instr  <= "01000000001101000101010010010011";
		Mux_sel  <= '1';
		AluCtrl <= "0010";
		wait for 10 ns;
		A <= std_logic_vector(to_signed(11,32));
		B <= std_logic_vector(to_signed(2,32));
		Mux_sel  <= '0';
		AluCtrl <= "0001";
		wait;
	end process;
	
		

end architecture RTL;
