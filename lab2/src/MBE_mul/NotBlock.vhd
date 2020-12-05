library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NotBlock is
	port(
		A              : in  std_logic_vector(32 downto 0);
		NotEnable      : in  std_logic;
		PartialProduct : out std_logic_vector(32 downto 0)
	);
end entity NotBlock;

architecture RTL of NotBlock is
	signal zero : std_logic_vector(32 downto 0);
begin
	zero <= (others  => '0');
	
	with NotEnable select PartialProduct <=
		A       when '0',
		not (A) when '1',
		zero    when others;
		
end architecture RTL;
