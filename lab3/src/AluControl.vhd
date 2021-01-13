library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AluControl is
	port(
		AluOp     : in  std_logic_vector(1 downto 0); --output of CU
		add_AluOp : in  std_logic_vector(3 downto 0); --instruction[30,14:12]
		MSB       : in  std_logic;
		AluCtrl   : out std_logic_vector(3 downto 0)
	);
end entity AluControl;

architecture RTL of AluControl is

	signal unique_code : std_logic_vector(5 downto 0); --signal useful to select the correct operation to execute by ALU

begin
	unique_code <= AluOp & add_AluOp;
	with unique_code select AluCtrl <=
		"0011" when "100000",           --ADD,LUI
		"0011" when "000000" | "001000", --ADDI
		"0000" when "000111" | "001111", --ANDI
		"0010" when "001101",           --SRAI
		"0001" when "100100",           --XOR
		"0011" when "000010" | "001010", --LW,SW
		"0111" when "010000" | "011000", --BEQ
		"0111" when "100010",           --SLT
		MSB & "011" when "000011",  --ABS
		--"1000" when ('1' & '1' & '0'|'1' & '0'|'1' & '0'|'1' & '0'|'1'),   --JAL
		"1000" when others;

end architecture RTL;
