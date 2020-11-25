library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fa is
	port(
		a : in std_logic;
		b : in std_logic;
		c_1 : in std_logic;
		sum : out std_logic;
		cout: out std_logic
	);
end entity fa;

architecture structural of fa is
	
begin

sum <= a xor b xor c_1;
cout <= (a and b) or (a and c_1) or (b and c_1);

end architecture structural;