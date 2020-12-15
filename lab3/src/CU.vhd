library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU is
	port(
		opcode   : in  std_logic_vector(6 downto 0);
		Branch   : out std_logic;
		MemRead  : out std_logic;
		MemToReg : out std_logic;
		AluOp    : out std_logic_vector(1 downto 0);
		MemWrite : out std_logic;
		AluSrc   : out std_logic;
		RegWrite : out std_logic;
		RegSrc : out std_logic_vector (1 downto 0)				--enable per il MUX per salvare in memoria
	);
end entity CU;

architecture RTL of CU is
	

begin
	with opcode select AluOp <=
		"10" when "0110011",	--R-type: ADD, XOR, SLT
	"00" when "0010011"|"0000011",		--I-type: ADDI, SRAI, ANDI, LW
	"01" when "1100011",		--B-type: BEQ
	"00" when "0010111"|"0110111",	--U-type: AUIPC, LUI
	"01" when "1101111",		--UJ-type: JAL
	"00" when "0100011",		--S-type: SW
	"11" when others;
	
	with opcode select Branch <=						
		'1' when "1100011"|"1101111",
		'0' when others;
		
	with opcode select MemRead <=
		'1' when "0000011",
		'0' when "0110011"|"0010011"|"1100011"|"0100011"|"0010111"|"0110111"|"1101111",
		'U' when others;
		
	---per dissipare meno, MemToReg è posto ad 1 quando il MUX non viene percorso
		
	with opcode select MemToReg <=
		'1' when "0000011"|"0100011"|"0010111"|"0110111"|"1101111",
		'0' when "0110011"|"0010011"|"1100011",
		'U' when others;
		
	with opcode select MemWrite <=
		'1' when "0100011"|"0100011",
		'0' when "0110011"|"0010011"|"1100011"|"0000011"|"0010111"|"0110111"|"1101111",
		'U' when others;
		
	with opcode select AluSrc <=
		'0' when "0110011"|"0010011"|"1100011"|"0010111"|"0110111"|"1101111",
		'1' when "0010011"|"0100011"|"0000011",
		'U' when others;
		
	with opcode select RegWrite <=
		'0' when "1100011"|"0100011",
		'1' when "0110011"|"0010011"|"0000011"|"0010111"|"0110111"|"1101111",
		'U' when others;
		
	---RegSrc:
	---0 : percorso standard
	---1 : percorso AUIPC
	---2 : percorso LUI
	---3 : percorso JAL
	
	with opcode select RegSrc <=		
		"01" when "0010111",
		"10" when "0110111",
		"11" when "1101111",
		"00" when others;
		
	
end architecture RTL;
