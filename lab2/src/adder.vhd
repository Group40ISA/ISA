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
	signal Sum_level1   : std_logic_vector(51 downto 0);

	signal Carry_level4 : std_logic_vector(105 downto 0);
	signal Sum_level4   : std_logic_vector(105 downto 0);

	signal Carry_level5 : std_logic_vector(58 downto 0);
	signal Sum_level5   : std_logic_vector(58 downto 0);

	signal Carry_level6 : std_logic_vector(61 downto 0);
	signal Sum_level6   : std_logic_vector(61 downto 0);

begin

	-- LEVEL 7 ----------------------------------------

	L1_HA1 : ha port map(Input_PP1(24), Input_PP2(24), Carry_level1(0), Sum_level1(0));

	L1_FA1 : fa port map(Input_PP1(25), Input_PP2(25), Input_PP3(23), Carry_level1(1), Sum_level1(1));

	L1_FA2 : fa port map(Input_PP1(26), Input_PP2(26), Input_PP3(24), Carry_level1(2), Sum_level1(2));
	L1_HA2 : ha port map(Input_PP4(22), Input_PP5(20), Carry_level1(3), Sum_level1(3));

	L1_FA3_1 : fa port map(Input_PP1(27), Input_PP2(27), Input_PP3(25), Carry_level1(4), Sum_level1(4));
	L1_FA3_2 : fa port map(Input_PP4(23), Input_PP5(21), Input_PP6(19), Carry_level1(5), Sum_level1(5));

	L1_FA4_1 : fa port map(Input_PP1(28), Input_PP2(28), Input_PP3(26), Carry_level1(6), Sum_level1(6));
	L1_FA4_2 : fa port map(Input_PP4(24), Input_PP5(22), Input_PP6(20), Carry_level1(7), Sum_level1(7));
	L1_HA4 : ha port map(Input_PP7(18), Input_PP8(16), Carry_level1(8), Sum_level1(8));

	L1_FA5_1 : fa port map(Input_PP1(29), Input_PP2(29), Input_PP3(27), Carry_level1(9), Sum_level1(9));
	L1_FA5_2 : fa port map(Input_PP4(25), Input_PP5(23), Input_PP6(21), Carry_level1(10), Sum_level1(10));
	L1_FA5_3 : fa port map(Input_PP7(19), Input_PP8(17), Input_PP9(15), Carry_level1(11), Sum_level1(11));

	L1_FA6_1 : fa port map(Input_PP1(30), Input_PP2(30), Input_PP3(28), Carry_level1(12), Sum_level1(12));
	L1_FA6_2 : fa port map(Input_PP4(26), Input_PP5(24), Input_PP6(22), Carry_level1(13), Sum_level1(13));
	L1_FA6_3 : fa port map(Input_PP7(20), Input_PP8(18), Input_PP9(16), Carry_level1(14), Sum_level1(14));
	L1_HA5 : ha port map(Input_PP10(14), Input_PP11(12), Carry_level1(15), Sum_level1(15));

	L1_FA_CENTRE : for I in 31 to 35 generate
		L1_REGX : fa
			port map(Input_PP1(I), Input_PP2(I), Input_PP3(I - 2), Carry_level1(16 + (I - 31) * 4), Sum_level1(16 + (I - 31) * 4));
		L1_REGY : fa
			port map(Input_PP1(I - 4), Input_PP2(I - 6), Input_PP3(I - 8), Carry_level1(17 + (I - 31) * 4), Sum_level1(17 + (I - 31) * 4));
		L1_REGZ : fa
			port map(Input_PP1(I - 10), Input_PP2(I - 12), Input_PP3(I - 14), Carry_level1(18 + (I - 31) * 4), Sum_level1(18 + (I - 31) * 4));
		L1_REGW : fa
			port map(Input_PP1(I - 16), Input_PP2(I - 18), Input_PP3(I - 20), Carry_level1(19 + (I - 31) * 4), Sum_level1(19 + (I - 31) * 4));
	end generate L1_FA_CENTRE;

	L1_HA9 : ha port map(Input_PP5(36), Input_PP6(34), Carry_level1(51), Sum_level1(51));

	L1_FA12 : fa port map(Input_PP5(35), Input_PP6(33), Input_PP7(31), Carry_level1(50), Sum_level1(50));

	L1_FA11 : fa port map(Input_PP4(36), Input_PP5(34), Input_PP6(32), Carry_level1(48), Sum_level1(48));
	L1_HA8 : ha port map(Input_PP7(30), Input_PP8(28), Carry_level1(49), Sum_level1(49));

	L1_FA10_1 : fa port map(Input_PP4(35), Input_PP5(33), Input_PP6(31), Carry_level1(46), Sum_level1(46));
	L1_FA10_2 : fa port map(Input_PP7(29), Input_PP8(27), Input_PP9(25), Carry_level1(47), Sum_level1(47));

	L1_FA9_1 : fa port map(Input_PP3(36), Input_PP4(34), Input_PP5(32), Carry_level1(43), Sum_level1(43));
	L1_FA9_2 : fa port map(Input_PP6(30), Input_PP7(28), Input_PP8(26), Carry_level1(44), Sum_level1(44));
	L1_HA7 : ha port map(Input_PP9(24), Input_PP10(22), Carry_level1(45), Sum_level1(45));

	L1_FA8_1 : fa port map(Input_PP3(35), Input_PP4(33), Input_PP5(31), Carry_level1(40), Sum_level1(40));
	L1_FA8_2 : fa port map(Input_PP6(29), Input_PP7(27), Input_PP8(25), Carry_level1(41), Sum_level1(41));
	L1_FA8_3 : fa port map(Input_PP9(23), Input_PP10(21), Input_PP11(19), Carry_level1(42), Sum_level1(42));

	L1_FA7_1 : fa port map(Input_PP2(36), Input_PP3(34), Input_PP4(32), Carry_level1(36), Sum_level1(36));
	L1_FA7_2 : fa port map(Input_PP5(30), Input_PP6(28), Input_PP7(26), Carry_level1(37), Sum_level1(37));
	L1_FA7_3 : fa port map(Input_PP8(24), Input_PP9(22), Input_PP10(20), Carry_level1(38), Sum_level1(38));
	L1_HA6 : ha port map(Input_PP11(18), Input_PP12(16), Carry_level1(39), Sum_level1(39));

	-- LEVEL 2 ----------------------------------------

	-- LEVEL 3 ----------------------------------------

	-- LEVEL 4 ----------------------------------------

	-- LEVEL 5 ----------------------------------------

	L5_HA1 : ha port map(Input_PP1(4), Input_PP2(4), Carry_level5(0), Sum_level5(0));

	L5_FA1 : fa port map(Input_PP1(5), Input_PP2(5), Input_PP3(3), Carry_level5(1), Sum_level5(1));

	L5_FA2 : fa port map(Sum_level4(0), Input_PP3(4), Input_PP4(2), Carry_level5(2), Sum_level5(2));

	L5_FA3 : fa port map(Carry_level4(0), Sum_level4(1), Input_PP4(3), Carry_level5(3), Sum_level5(3));

	L5_FA4 : fa port map(Carry_level4(1), Sum_level4(2), Sum_level4(3), Carry_level5(4), Sum_level5(4));

	L5_FA_CENTRE : for I in 5 to 55 generate
		L5_REGX : fa port map(Carry_level4(I - 3 + (I - 5)), Carry_level4(I - 2 + (I - 5)), Sum_level4(I - 1 + (I - 5)), Carry_level5(I), Sum_level5(I));
	end generate L5_FA_CENTRE;

	L5_FA5 : fa port map(Carry_level4(104), Sum_level4(105), Input_PP16(32), Carry_level5(56), Sum_level5(56));

	L5_FA6 : fa port map(Carry_level4(105), Input_PP14(36), Input_PP16(33), Carry_level5(57), Sum_level5(57));

	L5_HA7 : ha port map(Input_PP15(36), Input_PP16(34), Carry_level5(58), Sum_level5(58));

	-- LEVEL 6 ----------------------------------------

	L6_HA1 : ha port map(Input_PP1(2), Input_PP2(2), Carry_level6(0), Sum_level6(0));

	L6_FA1 : fa port map(Input_PP1(3), Input_PP2(3), Input_PP3(1), Carry_level6(1), Sum_level6(1));

	L6_FA2 : fa port map(Sum_level5(0), Input_PP3(2), Input_PP4(0), Carry_level6(2), Sum_level6(2));

	L6_FA3 : fa port map(Carry_level5(0), Sum_level5(1), Input_PP4(1), Carry_level6(3), Sum_level6(3));

	L6_FA4 : fa port map(Carry_level5(1), Sum_level5(2), Input_PP5(0), Carry_level6(4), Sum_level6(4));

	L6_FA5 : fa port map(Carry_level5(2), Sum_level5(3), Input_PP5(1), Carry_level6(5), Sum_level6(5));

	L6_FA6 : fa port map(Carry_level5(1), Sum_level5(2), Input_PP6(0), Carry_level6(6), Sum_level6(6));

	L6_FA_CENTRE : for I in 7 to 56 generate
		L5_REGX : fa port map(Carry_level5(I - 3), Sum_level5(I - 2), Sum_level4(I - 2 + (I - 7)), Carry_level6(I), Sum_level6(I));
	end generate L6_FA_CENTRE;

	L6_FA7 : fa port map(Carry_level5(54), Sum_level5(55), Input_PP17(30), Carry_level6(57), Sum_level6(57));

	L6_FA8 : fa port map(Carry_level5(55), Sum_level5(56), Input_PP17(31), Carry_level6(58), Sum_level6(58));

	L6_FA9 : fa port map(Carry_level5(56), Sum_level5(57), Input_PP17(32), Carry_level6(59), Sum_level6(59));

	L6_FA10 : fa port map(Carry_level5(57), Sum_level5(58), Input_PP17(33), Carry_level6(60), Sum_level6(60));

	L6_FA11 : fa port map(Carry_level5(58), Input_PP16(35), Input_PP17(34), Carry_level6(61), Sum_level6(61));

	-- OUT_RCA ----------------------------------------

	-- SUM OUT ----------------------------------------
	sum : process(SumEnable)
	begin
		if SumEnable = '1' then
			Output <= (others => '0');
		end if;
	end process sum;

end architecture RTL;
