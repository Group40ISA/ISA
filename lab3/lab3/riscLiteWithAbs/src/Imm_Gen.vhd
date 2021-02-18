library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Imm_Gen is
	port(
		instr : in std_logic_vector (31 downto 0);
		MSB : in std_logic;
		imm : out std_logic_vector (31 downto 0)
	);
end entity Imm_Gen;

architecture RTL of Imm_Gen is
	signal opcode : std_logic_vector (6 downto 0);
	signal ext : std_logic_vector (19 downto 0);
	signal imm_ADDI : std_logic_vector(31 downto 0);
	
begin
	opcode <= instr(6 downto 0);
	ext <= (others => instr(31)); -- signal used for the sign extension
	
	process(opcode,instr(14 downto 12),MSB, ext, instr(31 downto 20))
	begin
		if(opcode = "0010011") then --we do that to save power
			if(instr(14 downto 12) = "011") then
				if(MSB = '0') then
					imm_ADDI <= (others => '0');
				elsif (MSB = '1') then 
					imm_ADDI <= (0  => '1' , others => '0');
				else 
					imm_ADDI <= (others  => '0');
				end if;
			else
				imm_ADDI  <= ext & instr(31 downto 20);
			end if;
		else
			imm_ADDI <= (others => '0');
		end if;
	end process;
		
	with opcode select imm <=
		 ext & instr(31 downto 25) & instr(12 downto 8) when "0100011", --SW
		 imm_ADDI when "0010011", --ADDI,ANDI,SRAI
		 ext & instr(31 downto 20) when "0000011", --LW
		 ext(18 downto 0) & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0' when "1100011", --BEQ
		 instr(31 downto 12) & "000000000000" when "0010111"|"0110111", --AUIPC,LUI
		 ext(10 downto 0) & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21)& '0' when "1101111", --JAL
		 (others   => 'U') when others
		 ;
end architecture RTL;
