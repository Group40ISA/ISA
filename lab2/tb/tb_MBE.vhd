library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_MBE is
end entity tb_MBE;

architecture RTL of tb_MBE is
	component PartialProductGen
	port(
		clk         : in  std_logic;
		rst         : in  std_logic;
		x           : in  std_logic_vector(31 downto 0);
		A           : in  std_logic_vector(31 downto 0);
		Output_PP1  : out std_logic_vector(35 downto 0);
		Output_PP2  : out std_logic_vector(36 downto 0);
		Output_PP3  : out std_logic_vector(36 downto 0);
		Output_PP4  : out std_logic_vector(36 downto 0);
		Output_PP5  : out std_logic_vector(36 downto 0);
		Output_PP6  : out std_logic_vector(36 downto 0);
		Output_PP7  : out std_logic_vector(36 downto 0);
		Output_PP8  : out std_logic_vector(36 downto 0);
		Output_PP9  : out std_logic_vector(36 downto 0);
		Output_PP10 : out std_logic_vector(36 downto 0);
		Output_PP11 : out std_logic_vector(36 downto 0);
		Output_PP12 : out std_logic_vector(36 downto 0);
		Output_PP13 : out std_logic_vector(36 downto 0);
		Output_PP14 : out std_logic_vector(36 downto 0);
		Output_PP15 : out std_logic_vector(36 downto 0);
		Output_PP16 : out std_logic_vector(35 downto 0);
		Output_PP17 : out std_logic_vector(33 downto 0)
	);
end component PartialProductGen;

component adder is
	port(
		Input_PP1  : in  std_logic_vector(35 downto 0);
		Input_PP2  : in  std_logic_vector(36 downto 0);
		Input_PP3  : in  std_logic_vector(36 downto 0);
		Input_PP4  : in  std_logic_vector(36 downto 0);
		Input_PP5  : in  std_logic_vector(36 downto 0);
		Input_PP6  : in  std_logic_vector(36 downto 0);
		Input_PP7  : in  std_logic_vector(36 downto 0);
		Input_PP8  : in  std_logic_vector(36 downto 0);
		Input_PP9  : in  std_logic_vector(36 downto 0);
		Input_PP10 : in  std_logic_vector(36 downto 0);
		Input_PP11 : in  std_logic_vector(36 downto 0);
		Input_PP12 : in  std_logic_vector(36 downto 0);
		Input_PP13 : in  std_logic_vector(36 downto 0);
		Input_PP14 : in  std_logic_vector(36 downto 0);
		Input_PP15 : in  std_logic_vector(36 downto 0);
		Input_PP16 : in  std_logic_vector(35 downto 0);
		Input_PP17 : in  std_logic_vector(33 downto 0);
		Output     : out std_logic_vector(63 downto 0)
	);
end component adder;

	signal clk, rst          : std_logic;
	signal x, A : std_logic_vector(31 downto 0);
	signal Output_PP2,Output_PP3,output_PP4 : std_logic_vector(36 downto 0);
	signal Output_PP5,Output_PP6,output_PP7 : std_logic_vector(36 downto 0);
	signal Output_PP8,Output_PP9,output_PP10 : std_logic_vector(36 downto 0);
	signal Output_PP11,Output_PP12,output_PP13 : std_logic_vector(36 downto 0);
	signal Output_PP14,Output_PP15 : std_logic_vector(36 downto 0);
	signal Output_PP1,Output_PP16 : std_logic_vector(35 downto 0);
	signal Output_PP17 : std_logic_vector(33 downto 0);
	signal Output : std_logic_vector(63 downto 0);

begin

	PP_gen : PartialProductGen
		port map(
			clk         => clk,
			rst         => rst,
			x           => x,
			A           => A,
			Output_PP1  => Output_PP1,
			Output_PP2  => Output_PP2,
			Output_PP3  => Output_PP3,
			Output_PP4  => output_PP4,
			Output_PP5  => Output_PP5,
			Output_PP6  => Output_PP6,
			Output_PP7  => output_PP7,
			Output_PP8  => Output_PP8,
			Output_PP9  => Output_PP9,
			Output_PP10 => output_PP10,
			Output_PP11 => Output_PP11,
			Output_PP12 => Output_PP12,
			Output_PP13 => output_PP13,
			Output_PP14 => Output_PP14,
			Output_PP15 => Output_PP15,
			Output_PP16 => Output_PP16,
			Output_PP17 => Output_PP17
		);
		
	adder1: adder port map(
		Input_PP1  => Output_PP1,
		Input_PP2  => Output_PP2,
		Input_PP3  => Output_PP3,
		Input_PP4  => output_PP4,
		Input_PP5  => Output_PP5,
		Input_PP6  => Output_PP6,
		Input_PP7  => output_PP7,
		Input_PP8  => Output_PP8,
		Input_PP9  => Output_PP9,
		Input_PP10 => output_PP10,
		Input_PP11 => Output_PP11,
		Input_PP12 => Output_PP12,
		Input_PP13 => output_PP13,
		Input_PP14 => Output_PP14,
		Input_PP15 => Output_PP15,
		Input_PP16 => Output_PP16,
		Input_PP17 => Output_PP17,
		Output     => Output
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
		A   <= std_logic_vector(to_unsigned(140, 32));
		x   <= std_logic_vector(to_unsigned(3, 32));
		wait;
	end process stimuli;

end architecture RTL;
