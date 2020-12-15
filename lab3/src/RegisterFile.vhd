library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFile is
	port(
		 RReg1 : in std_logic_vector (4 downto 0);
		 RReg2 : in std_logic_vector (4 downto 0);
		 WReg :  in std_logic_vector (4 downto 0);
		 WData : in std_logic_vector (31 downto 0);
		 RegWrite : in std_logic;
		 Read1 : out std_logic_vector (31 downto 0);
		 Read2 : out std_logic_vector (31 downto 0)
	);
	
end entity RegisterFile;

architecture RTL of RegisterFile is
	
	type RF is array (0 to 31) of std_logic_vector(31 downto 0);
	signal RegF : RF;
		
begin
	RegF(0) <= (others => '0');
	Read1 <= RegF (to_integer(unsigned (RReg1)));
	Read2 <= RegF (to_integer(unsigned (RReg2)));
	
	process(RegWrite, WData, WReg)
	begin
		if (RegWrite = '1') then
			RegF (to_integer(unsigned (WReg))) <= WData;
		end if;
	end process;
			
end architecture RTL;
