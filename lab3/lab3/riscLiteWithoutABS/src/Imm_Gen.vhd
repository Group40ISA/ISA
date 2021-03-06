library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ImmGen is
	port(
		instr : in std_logic_vector (31 downto 0);
		imm : out std_logic_vector (31 downto 0)
	);
end entity ImmGen;

architecture RTL of ImmGen is
	signal opcode : std_logic_vector (6 downto 0);
	signal ext : std_logic_vector (19 downto 0);
	
begin
	opcode <= instr(6 downto 0);
	ext <= (others => instr(31));
	with opcode select imm <=
		 ext & instr(31 downto 25) & instr(12 downto 8) when "0100011",
		 ext & instr(31 downto 20) when "0010011"|"0000011", --ADDI,ANDI,LW,SRAI
		 ext(18 downto 0) & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0' when "1100011", --BEQ
		 instr(31 downto 12) & "000000000000" when "0010111"|"0110111", --AUIPC,LUI
		 ext(10 downto 0) & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21)& '0' when "1101111", --JAL
		 (others   => 'U') when others
		 ;
end architecture RTL;
