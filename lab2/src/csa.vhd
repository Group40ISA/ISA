library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity csa is
	generic(nfa : integer := 11; nha : integer := 3; height: integer :=3;layer: integer :=1);
	port(
		A : in  std_logic_vector(((3 * nfa) + (2 * nha)) downto 0);
		O : out std_logic_vector(((2 * nha) + (2 * nfa)) downto 0)
	);
end entity csa;

architecture RTL of csa is
begin
csa:for i in 0 to layer-1 generate
l1: if i = 0 GENERATE


end GENERATE l1;
l2:if i=1 generate
	
	
end generate l2;

l3:if i=2 generate
	
end generate l3;

l4:if i=3 generate
	
end generate l4;

l5:if i=4 generate
	
end generate l5;

l6:if i=5 generate
	
end generate l6;

end generate csa;

end architecture RTL;
