library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MBE_tab is
	port(
		Input : in std_logic_vector(2 downto 0);
		Mux_Select : out std_logic_vector(1 downto 0);
		NotEnable : out std_logic
	);
end entity MBE_tab;

architecture RTL of MBE_tab is
	signal Output : std_logic_vector(2 downto 0);
begin
with Input select Output <=
	"000" when "000",         -- +0
	"001" when "111",         -- -0
	"010" when "001" | "010", -- +a
	"011" when "101" | "110", -- -a
	"100" when "011",         -- +2a
	"101" when "100",         -- -2a
	"000" when others;
	
	Mux_Select <= Output(2 downto 1);
	NotEnable <= Output(0);
end architecture RTL;
