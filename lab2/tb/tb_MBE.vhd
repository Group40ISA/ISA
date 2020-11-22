library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MBE is
end entity tb_MBE;

architecture RTL of tb_MBE is
	component PartialProductGen
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			x          : in  std_logic_vector(7 downto 0);
			A          : in  std_logic_vector(7 downto 0);
			OE         : out std_logic;
			Output_PP1 : out std_logic_vector(11 downto 0);
			Output_PP2 : out std_logic_vector(12 downto 0);
			Output_PP3 : out std_logic_vector(12 downto 0);
			Output_PP4 : out std_logic_vector(11 downto 0);
			Output_PP5 : out std_logic_vector(10 downto 0)
		);
	end component PartialProductGen;
	signal clk, rst          : std_logic;
	signal x, A : std_logic_vector(7 downto 0);
	signal OE_sig : std_logic;
	signal Output_PP2,Output_PP3 : std_logic_vector(12 downto 0);
	signal Output_PP1,Output_PP4 : std_logic_vector(11 downto 0);
	signal Output_PP5 : std_logic_vector(10 downto 0);

begin

	PP_gen : PartialProductGen
		port map(
			clk         => clk,
			rst         => rst,
			x           => x,
			A           => A,
			OE          => OE_sig,
			Output_PP1  => Output_PP1,
			Output_PP2  => Output_PP2,
			Output_PP3  => Output_PP3,
			Output_PP4  => Output_PP4,
			Output_PP5  => Output_PP5
		);

	clk_proc : process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process clk_proc;

	stimuli : process
	begin
		rst <= '0';
		wait for 1 ns;
		rst <= '1';
		A   <= std_logic_vector(to_unsigned(140, 8));
		x   <= std_logic_vector(to_unsigned(3, 8));
		wait;
	end process stimuli;

end architecture RTL;
