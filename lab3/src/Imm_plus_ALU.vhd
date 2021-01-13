library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Imm_plus_ALU is
	port(
		A, B : in std_logic_vector (31 downto 0);
		AluCtrl : in std_logic_vector (3 downto 0);
		instr : in std_logic_vector (31 downto 0);
		Mux_sel : in std_logic;
		zero : out std_logic; 
		result: out std_logic_vector (31 downto 0)
	);
end entity Imm_plus_ALU;

architecture RTL of Imm_plus_ALU is
	component ALU is
	port(
		A, B : in std_logic_vector (31 downto 0);
		AluCtrl : in std_logic_vector (3 downto 0);
		zero : out std_logic; 
		result: out std_logic_vector (31 downto 0)
	);
end component ALU;

	component Imm_Gen is
		port(
		instr : in std_logic_vector (31 downto 0);
		imm : out std_logic_vector (31 downto 0)
	);
end component Imm_Gen;

	signal imm : std_logic_vector(31 downto 0);
	signal Mux_out : std_logic_vector(31 downto 0);

begin

	ALU1: ALU port map(
		A       => A,
		B       => Mux_out,
		AluCtrl => AluCtrl,
		zero    => zero,
		result  => result
	);
	Imm1: Imm_Gen port map(
		instr => instr,
		imm   => imm
	);
	
	with Mux_sel select Mux_out <=
		B when '0',
		imm when '1',
		(others   => 'U') when others
	;
	
end architecture RTL;
