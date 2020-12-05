library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
	generic(levelPipe : integer := 6);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		D   : in  std_logic;
		Q   : out std_logic
	);
end entity shift;

architecture RTL of shift is

	signal tmp : std_logic_vector(levelPipe - 1 downto 0);

begin
	process(clk, rst)
	begin
		if rst = '0' then
			tmp <= (others => '0');
		elsif clk'event and clk = '1' then
					tmp(levelPipe - 2 downto 0) <= tmp(levelPipe - 1 downto 1);
					tmp(levelPipe - 1)          <= D;
		end if;
	end process;
	Q <= tmp(0);
end architecture RTL;
