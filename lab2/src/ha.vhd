library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hd is
	port(
		a : in std_logic;
		b : in std_logic;
		sum_ha :out std_logic;
		cout_ha:out std_logic
	);
end entity hd;

architecture RTL of hd is
	
begin

sum_ha <= a xor b;
cout_ha <= a and b;

end architecture RTL;
