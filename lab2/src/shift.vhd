library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift is
	generic(parallelism : integer := 8);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		D   : in  std_logic_vector(parallelism-1 downto 0);
		Q   : out std_logic_vector(2 downto 0)
	);
end entity shift;

architecture RTL of shift is

	signal tmp : std_logic_vector(parallelism - 1 + 3 downto 0);

begin
	process(clk, rst)
	variable save : std_logic := '1';
	variable count: integer := 0;
	begin
		if rst = '0' then
			tmp <= (others => '0');
		elsif clk'event and clk = '1' then
			if save = '1' then
				tmp <= "00" & D & '0';
				save := '0';
			elsif save = '0' then
				tmp(parallelism-3+3 downto 0) <= tmp(parallelism-1+3 downto 2); 
				tmp(parallelism-1+3 downto parallelism-2+3) <= "00";
				count := count + 2;
				if count = parallelism+3 then
					save := '1';
					count := 0;
				end if;
			end if;
		end if;
	end process;
	Q <= tmp(2 downto 0);
end architecture RTL;
