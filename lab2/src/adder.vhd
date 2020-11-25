library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	port(
		SumEnable  : in  std_logic;
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
		Input_PP17 : in  std_logic_vector(34 downto 0);
		Output     : out std_logic_vector(63 downto 0)
	);
end entity adder;

architecture RTL of adder is

	component fa is
		port(
			a       : in  std_logic;
			b       : in  std_logic;
			c_1     : in  std_logic;
			sum_fa  : out std_logic;
			cout_fa : out std_logic
		);
	end component fa;

	component ha is
		port(
			a       : in  std_logic;
			b       : in  std_logic;
			sum_ha  : out std_logic;
			cout_ha : out std_logic
		);
	end component ha;
	
	signal Carry_level1 : std_logic_vector(51 downto 0);
	signal Sum_level1 : std_logic_vector(51 downto 0);
	

begin

	-- LEVEL 1 ----------------------------------------

	HA1 : ha port map(Input_PP1(25), Input_PP2(25),Carry_level1(0),Sum_level1(0));

	FA1 : fa port map(Input_PP1(26), Input_PP2(26), Input_PP3(24),Carry_level1(1),Sum_level1(1));

	FA2 : fa port map(Input_PP1(27), Input_PP2(27), Input_PP3(25),Carry_level1(2),Sum_level1(2));
	HA2 : ha port map(Input_PP4(23), Input_PP5(21),Carry_level1(3),Sum_level1(3));

	FA3_1 : fa port map(Input_PP1(28), Input_PP2(28), Input_PP3(26),Carry_level1(4),Sum_level1(4));
	FA3_2 : fa port map(Input_PP4(24), Input_PP5(22), Input_PP6(20),Carry_level1(5),Sum_level1(5));

	FA4_1 : fa port map(Input_PP1(29), Input_PP2(29), Input_PP3(27),Carry_level1(6),Sum_level1(6));
	FA4_2 : fa port map(Input_PP4(25), Input_PP5(23), Input_PP6(21),Carry_level1(7),Sum_level1(7));
	HA4 : ha port map(Input_PP7(19), Input_PP8(17),Carry_level1(7),Sum_level1(7));

	FA5_1 : fa port map(Input_PP1(30), Input_PP2(30), Input_PP3(28),Carry_level1(8),Sum_level1(8));
	FA5_2 : fa port map(Input_PP4(26), Input_PP5(24), Input_PP6(22),Carry_level1(9),Sum_level1(9));
	FA5_3 : fa port map(Input_PP7(20), Input_PP8(18), Input_PP9(16),Carry_level1(10),Sum_level1(10));

	FA6_1 : fa port map(Input_PP1(31), Input_PP2(31), Input_PP3(29),Carry_level1(11),Sum_level1(11));
	FA6_2 : fa port map(Input_PP4(27), Input_PP5(25), Input_PP6(23),Carry_level1(12),Sum_level1(12));
	FA6_3 : fa port map(Input_PP7(21), Input_PP8(19), Input_PP9(17),Carry_level1(13),Sum_level1(13));
	HA5 : ha port map(Input_PP10(15), Input_PP11(13),Carry_level1(14),Sum_level1(14));

	FA_CENTRE : for I in 32 to 36 generate
		REGX : fa
			port map(Input_PP1(I), Input_PP2(I), Input_PP3(I - 2),Carry_level1(I - 32 + 15),Sum_level1(I - 32 + 15));
		REGY : fa
			port map(Input_PP1(I - 4), Input_PP2(I - 6), Input_PP3(I - 8),Carry_level1(I - 32 + 16),Sum_level1(I - 32 + 16));
		REGZ : fa
			port map(Input_PP1(I - 10), Input_PP2(I - 12), Input_PP3(I - 14),Carry_level1(I - 32 + 17),Sum_level1(I - 32 + 17));
		REGW : fa
			port map(Input_PP1(I - 16), Input_PP2(I - 18), Input_PP3(I - 20),Carry_level1(I - 32 + 18),Sum_level1(I - 32 + 18));
	end generate FA_CENTRE;

	HA9 : ha port map(Input_PP5(37), Input_PP6(35));

	FA12 : fa port map(Input_PP5(36), Input_PP6(34), Input_PP7(32));

	FA11 : fa port map(Input_PP4(37), Input_PP5(35), Input_PP6(33));
	HA8 : ha port map(Input_PP7(31), Input_PP8(29));

	FA10_1 : fa port map(Input_PP4(36), Input_PP5(34), Input_PP6(32));
	FA10_2 : fa port map(Input_PP7(30), Input_PP8(28), Input_PP9(26));

	FA9_1 : fa port map(Input_PP3(37), Input_PP4(35), Input_PP5(33));
	FA9_2 : fa port map(Input_PP6(31), Input_PP7(29), Input_PP8(27));
	HA7 : ha port map(Input_PP9(25), Input_PP10(23));

	FA8_1 : fa port map(Input_PP3(36), Input_PP4(34), Input_PP5(32));
	FA8_2 : fa port map(Input_PP6(30), Input_PP7(28), Input_PP8(26));
	FA8_3 : fa port map(Input_PP9(24), Input_PP10(22), Input_PP11(20));

	FA7_1 : fa port map(Input_PP2(37), Input_PP3(35), Input_PP4(33));
	FA7_2 : fa port map(Input_PP5(31), Input_PP6(29), Input_PP7(27));
	FA7_3 : fa port map(Input_PP8(25), Input_PP9(23), Input_PP10(21));
	HA6 : ha port map(Input_PP11(19), Input_PP12(17));

	-- LEVEL 2 ----------------------------------------

	-- LEVEL 3 ----------------------------------------

	-- LEVEL 4 ----------------------------------------

	-- LEVEL 5 ----------------------------------------

	-- LEVEL 6 ----------------------------------------

	-- OUT_RCA ----------------------------------------

	sum : process(SumEnable)
	begin
		if SumEnable = '1' then
			Output <= (others => '0');
		end if;
	end process sum;

end architecture RTL;
