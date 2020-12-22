library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFile is
	port(clk : in std_logic;
	 	 rst : in std_logic;
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
	Read1 <= RegF (to_integer(unsigned (RReg1)));
	Read2 <= RegF (to_integer(unsigned (RReg2)));
	
	process(RegWrite, WData, WReg, rst)
	begin
		if (rst = '1') then
			RegF <= (others => (others => '0'));
		elsif clk'event and clk = '0' then
			if(RegWrite = '1' and to_integer(unsigned(Wreg)) /= 0) then -- TODO: control for x0
				RegF (to_integer(unsigned (WReg))) <= WData;
			end if;
		end if;
	end process;
			
end architecture RTL;
