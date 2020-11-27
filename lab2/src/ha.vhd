library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ha is
	port(
		a : in std_logic;
		b : in std_logic;
		cout_ha:out std_logic;
		sum_ha :out std_logic
	);
end entity ha;

architecture RTL of ha is
	
begin

sum_ha <= a xor b;
cout_ha <= a and b;

end architecture RTL;
