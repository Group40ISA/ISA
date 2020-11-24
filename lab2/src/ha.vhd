library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hd is
	port(
		a : in std_logic;
		b : in std_logic;
		sum:out std_logic;
		cout:out std_logic
	);
end entity hd;

architecture RTL of hd is
	
begin

sum <= a xor b;
cout <= a and b;

end architecture RTL;
