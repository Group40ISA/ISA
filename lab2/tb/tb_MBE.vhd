library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MBE is
end entity tb_MBE;

architecture RTL of tb_MBE is
	
	component mul is
		port(x : in std_logic_vector(31 downto 0);
        A : in std_logic_vector(31 downto 0);
        p : out std_logic_vector(63 downto 0));
	end component mul;

	signal x, A : std_logic_vector(31 downto 0);
	signal Product : std_logic_vector(63 downto 0);

begin
	
	MULT: mul port map(x,A,Product);

	stimuli : process
	begin
		A   <= "10000000000000000000000000000000";
		x   <= "00000000000000000000000000000110";
		wait;
	end process stimuli;

end architecture RTL;
