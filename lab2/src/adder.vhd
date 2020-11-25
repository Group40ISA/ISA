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
		Input_PP17 : in  std_logic_vector(33 downto 0);
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
	
	signal Carry_level2 : std_logic_vector(115 downto 0);
	signal Sum_level2 : std_logic_vector(115 downto 0);

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
L2_HA1 : ha port map(Input_PP1(16), Input_PP2(16),Carry_level2(0),Sum_level2(0));
    
    L2_FA1 : fa port map(Input_PP1(17), Input_PP2(17), Input_PP3(15),Carry_level2(1),Sum_level2(1));
    
    L2_FA2 : fa port map(Input_PP1(18), Input_PP2(18), Input_PP3(16),Carry_level2(2),Sum_level2(2));
	L2_HA2 : ha port map(Input_PP4(14), Input_PP5(12),Carry_level2(3),Sum_level2(3));
	
	L2_FA3_1 : fa port map(Input_PP1(19), Input_PP2(19), Input_PP3(17),Carry_level2(4),Sum_level2(4));
	L2_FA3_2 : fa port map(Input_PP4(15), Input_PP5(13), Input_PP6(11),Carry_level2(5),Sum_level2(5));
	
	L2_FA4_1 : fa port map(Input_PP1(20), Input_PP2(20), Input_PP3(18),Carry_level2(6),Sum_level2(6));
	L2_FA4_2 : fa port map(Input_PP4(16), Input_PP5(14), Input_PP6(12),Carry_level2(7),Sum_level2(7));
	L2_HA3 : ha port map(Input_PP7(10), Input_PP8(8),Carry_level2(8),Sum_level2(8));
	
	L2_FA5_1 : fa port map(Input_PP1(21), Input_PP2(21), Input_PP3(19),Carry_level2(9),Sum_level2(9));
	L2_FA5_2 : fa port map(Input_PP4(17), Input_PP5(15), Input_PP6(13),Carry_level2(10),Sum_level2(10));
	L2_FA5_3 : fa port map(Input_PP7(11), Input_PP8(9), Input_PP9(7),Carry_level2(11),Sum_level2(11));
	
	L2_FA6_1 : fa port map(Input_PP1(22), Input_PP2(22), Input_PP3(20),Carry_level2(12),Sum_level2(12));
	L2_FA6_2 : fa port map(Input_PP4(18), Input_PP5(16), Input_PP6(14),Carry_level2(13),Sum_level2(13));
	L2_FA6_3 : fa port map(Input_PP7(12), Input_PP8(10), Input_PP9(8),Carry_level2(14),Sum_level2(14));
	L2_HA4 : ha port map(Input_PP10(6), Input_PP11(4),Carry_level2(15),Sum_level2(15));
	
	L2_FA7_1 : fa port map(Input_PP1(23), Input_PP2(23), Input_PP3(21),Carry_level2(16),Sum_level2(16));
	L2_FA7_2 : fa port map(Input_PP4(19), Input_PP5(17), Input_PP6(15),Carry_level2(17),Sum_level2(17));
	L2_FA7_3 : fa port map(Input_PP7(13), Input_PP8(11), Input_PP9(9),Carry_level2(18),Sum_level2(18));
	L2_FA7_4 : fa port map(Input_PP10(7), Input_PP11(5), Input_PP12(3),Carry_level2(19),Sum_level2(19));
	
	L2_FA8_1 : fa port map(Sum_level1(0), Input_PP3(22), Input_PP4(20),Carry_level2(20),Sum_level2(20));
	L2_FA8_2 : fa port map(Input_PP5(18), Input_PP6(16), Input_PP7(14),Carry_level2(21),Sum_level2(21));
	L2_FA8_3 : fa port map(Input_PP8(12), Input_PP9(10), Input_PP10(8),Carry_level2(22),Sum_level2(22));
	L2_FA8_4 : fa port map(Input_PP11(6), Input_PP12(4), Input_PP13(2),Carry_level2(23),Sum_level2(23));
	
	L2_FA9_1 : fa port map(Carry_level1(0), Sum_level1(1), Input_PP4(21),Carry_level2(24),Sum_level2(24));
	L2_FA9_2 : fa port map(Input_PP5(19), Input_PP6(17), Input_PP7(15),Carry_level2(25),Sum_level2(25));
	L2_FA9_3 : fa port map(Input_PP8(13), Input_PP9(11), Input_PP10(9),Carry_level2(26),Sum_level2(26));
	L2_FA9_4 : fa port map(Input_PP11(7), Input_PP12(5), Input_PP13(3),Carry_level2(27),Sum_level2(27));
	
	L2_FA10_1 : fa port map(Carry_level1(1), Sum_level1(2), Sum_level1(3),Carry_level2(28),Sum_level2(28));
	L2_FA10_2 : fa port map(Input_PP6(18), Input_PP7(16), Input_PP8(14),Carry_level2(29),Sum_level2(29));
	L2_FA10_3 : fa port map(Input_PP9(12), Input_PP10(10), Input_PP11(8),Carry_level2(30),Sum_level2(30));
	L2_FA10_4 : fa port map(Input_PP12(6), Input_PP13(4), Input_PP14(2),Carry_level2(31),Sum_level2(31));
	
	L2_FA11_1 : fa port map(Carry_level1(2), Carry_level1(3), Sum_level1(4),Carry_level2(32),Sum_level2(32));
	L2_FA11_2 : fa port map(Sum_level1(5), Input_PP7(17), Input_PP8(15),Carry_level2(33),Sum_level2(33));
	L2_FA11_3 : fa port map(Input_PP9(13), Input_PP10(11), Input_PP11(9),Carry_level2(34),Sum_level2(34));
	L2_FA11_4 : fa port map(Input_PP12(7), Input_PP13(5), Input_PP14(3),Carry_level2(35),Sum_level2(35));
	
	L2_FA12_1 : fa port map(Carry_level1(4), Carry_level1(5), Sum_level1(6),Carry_level2(36),Sum_level2(36));
	L2_FA12_2 : fa port map(Sum_level1(7), Sum_level1(8), Input_PP9(14),Carry_level2(37),Sum_level2(37));
	L2_FA12_3 : fa port map(Input_PP10(12), Input_PP11(10), Input_PP12(8),Carry_level2(38),Sum_level2(38));
	L2_FA12_4 : fa port map(Input_PP13(6), Input_PP14(4), Input_PP15(2),Carry_level2(39),Sum_level2(39));
	
	L2_FA13_1 : fa port map(Carry_level1(6), Carry_level1(7), Carry_level1(8),Carry_level2(40),Sum_level2(40));
	L2_FA13_2 : fa port map(Sum_level1(9), Sum_level1(10), Sum_level1(11),Carry_level2(41),Sum_level2(41));
	L2_FA13_3 : fa port map(Input_PP10(13), Input_PP11(11), Input_PP12(9),Carry_level2(42),Sum_level2(42));
	L2_FA13_4 : fa port map(Input_PP13(7), Input_PP14(5), Input_PP15(3),Carry_level2(43),Sum_level2(43));
	
	L2_FA14_1 : fa port map(Carry_level1(9), Carry_level1(10), Carry_level1(11),Carry_level2(44),Sum_level2(44));
	L2_FA14_2 : fa port map(Sum_level1(12), Sum_level1(13), Sum_level1(14),Carry_level2(45),Sum_level2(45));
	L2_FA14_3 : fa port map(Sum_level1(15), Input_PP12(10), Input_PP13(8),Carry_level2(46),Sum_level2(46));
	L2_FA14_4 : fa port map(Input_PP14(6), Input_PP15(4), Input_PP16(2),Carry_level2(47),Sum_level2(47));
	
	FA_CENTRE2 : for I in 31 to 36 generate
		L2_REGX : fa
			port map(Carry_level1(12+(I-31)*4), Carry_level1(13+(I-31)*4), Carry_level1(14+(I-31)*4),Carry_level2(48+(I - 31)*4),Sum_level2(48+(I - 31)*4));
		L2_REGY : fa
			port map(Carry_level1(15+(I-31)*4), Sum_level1(16+(I-31)*4), Sum_level1(17+(I-31)*4),Carry_level2(49+(I - 31)*4),Sum_level2(49+(I - 31)*4));
		L2_REGZ : fa
			port map(Sum_level1(18+(I-31)*4), Sum_level1(19+(I-31)*4), Input_PP13(I - 22),Carry_level2(50+(I - 31)*4),Sum_level2(50+(I - 31)*4));
		L2_REGW : fa
			port map(Input_PP14(I - 24), Input_PP15(I - 26), Input_PP16(I - 28),Carry_level2(51+(I - 31)*4),Sum_level2(51+(I - 31)*4));
	end generate FA_CENTRE2;
	
	L2_FA15_1 : fa port map(Carry_level1(36), Carry_level1(37), Carry_level1(38),Carry_level2(72),Sum_level2(72));
	L2_FA15_2 : fa port map(Carry_level1(39), Sum_level1(40), Sum_level1(41),Carry_level2(73),Sum_level2(73));
	L2_FA15_3 : fa port map(Sum_level1(42), Input_PP12(17), Input_PP13(15),Carry_level2(74),Sum_level2(74));
	L2_FA15_4 : fa port map(Input_PP14(13), Input_PP15(11), Input_PP16(9),Carry_level2(75),Sum_level2(75));
	
	L2_FA16_1 : fa port map(Carry_level1(40), Carry_level1(41), Carry_level1(42),Carry_level2(76),Sum_level2(76));
	L2_FA16_2 : fa port map(Sum_level1(43), Sum_level1(44), Sum_level1(45),Carry_level2(77),Sum_level2(77));
	L2_FA16_3 : fa port map(Input_PP11(20), Input_PP12(18), Input_PP13(16),Carry_level2(78),Sum_level2(78));
	L2_FA16_4 : fa port map(Input_PP14(14), Input_PP15(12), Input_PP16(10),Carry_level2(79),Sum_level2(79));
	
	L2_FA17_1 : fa port map(Carry_level1(43), Carry_level1(44), Carry_level1(45),Carry_level2(80),Sum_level2(80));
	L2_FA17_2 : fa port map(Sum_level1(46), Sum_level1(47), Input_PP10(23),Carry_level2(81),Sum_level2(81));
	L2_FA17_3 : fa port map(Input_PP11(21), Input_PP12(19), Input_PP13(17),Carry_level2(82),Sum_level2(82));
	L2_FA17_4 : fa port map(Input_PP14(15), Input_PP15(13), Input_PP16(11),Carry_level2(83),Sum_level2(83));
	
	L2_FA18_1 : fa port map(Carry_level1(46), Carry_level1(47), Sum_level1(48),Carry_level2(84),Sum_level2(84));
	L2_FA18_2 : fa port map(Sum_level1(49), Input_PP9(26), Input_PP10(24),Carry_level2(85),Sum_level2(85));
	L2_FA18_3 : fa port map(Input_PP11(22), Input_PP12(20), Input_PP13(18),Carry_level2(86),Sum_level2(86));
	L2_FA18_4 : fa port map(Input_PP14(16), Input_PP15(14), Input_PP16(12),Carry_level2(87),Sum_level2(87));
	
	L2_FA19_1 : fa port map(Carry_level1(48), Carry_level1(49), Sum_level1(50),Carry_level2(88),Sum_level2(88));
	L2_FA19_2 : fa port map(Input_PP8(29), Input_PP9(27), Input_PP10(25),Carry_level2(89),Sum_level2(89));
	L2_FA19_3 : fa port map(Input_PP11(23), Input_PP12(21), Input_PP13(19),Carry_level2(90),Sum_level2(90));
	L2_FA19_4 : fa port map(Input_PP14(17), Input_PP15(15), Input_PP16(13),Carry_level2(91),Sum_level2(91));
	
	L2_FA20_1 : fa port map(Carry_level1(50), Sum_level1(51), Input_PP7(32),Carry_level2(92),Sum_level2(92));
	L2_FA20_2 : fa port map(Input_PP8(30), Input_PP9(28), Input_PP10(26),Carry_level2(93),Sum_level2(93));
	L2_FA20_3 : fa port map(Input_PP11(24), Input_PP12(22), Input_PP13(20),Carry_level2(94),Sum_level2(94));
	L2_FA20_4 : fa port map(Input_PP14(18), Input_PP15(16), Input_PP16(14),Carry_level2(95),Sum_level2(95));
	
	L2_FA21_1 : fa port map(Carry_level1(51), Input_PP6(35), Input_PP7(33),Carry_level2(96),Sum_level2(96));
	L2_FA21_2 : fa port map(Input_PP8(31), Input_PP9(29), Input_PP10(27),Carry_level2(97),Sum_level2(97));
	L2_FA21_3 : fa port map(Input_PP11(25), Input_PP12(23), Input_PP13(21),Carry_level2(98),Sum_level2(98));
	L2_FA21_4 : fa port map(Input_PP14(19), Input_PP15(17), Input_PP16(15),Carry_level2(99),Sum_level2(99));
	
	L2_FA22_1 : fa port map(Input_PP6(36), Input_PP7(34), Input_PP8(32),Carry_level2(100),Sum_level2(100));
	L2_FA22_2 : fa port map(Input_PP9(30), Input_PP10(28), Input_PP11(26),Carry_level2(101),Sum_level2(101));
	L2_FA22_3 : fa port map(Input_PP12(24), Input_PP13(22), Input_PP14(20),Carry_level2(102),Sum_level2(102));
	L2_HA5 : ha port map(Input_PP15(18), Input_PP16(16),Carry_level2(103),Sum_level2(103));
	
	L2_FA23_1 : fa port map(Input_PP7(35), Input_PP8(33), Input_PP9(31),Carry_level2(104),Sum_level2(104));
	L2_FA23_2 : fa port map(Input_PP10(29), Input_PP11(27), Input_PP12(25),Carry_level2(105),Sum_level2(105));
	L2_FA23_3 : fa port map(Input_PP13(23), Input_PP14(21), Input_PP15(19),Carry_level2(106),Sum_level2(106));
	
	L2_FA24_1 : fa port map(Input_PP7(36), Input_PP8(34), Input_PP9(32),Carry_level2(107),Sum_level2(107));
	L2_FA24_2 : fa port map(Input_PP10(30), Input_PP11(28), Input_PP12(26),Carry_level2(108),Sum_level2(108));
	L2_HA6 : ha port map(Input_PP13(24), Input_PP14(22),Carry_level2(109),Sum_level2(109));
	
	L2_FA25_1 : fa port map(Input_PP8(35), Input_PP9(33), Input_PP10(31),Carry_level2(110),Sum_level2(110));
	L2_FA25_2 : fa port map(Input_PP11(29), Input_PP12(27), Input_PP13(25),Carry_level2(111),Sum_level2(111));
	
	L2_FA26 : fa port map(Input_PP8(36), Input_PP9(34), Input_PP10(32),Carry_level2(112),Sum_level2(112));
	L2_HA7 : ha port map(Input_PP11(30), Input_PP12(28),Carry_level2(113),Sum_level2(113));
	
	L2_FA27 : fa port map(Input_PP9(35), Input_PP10(33), Input_PP11(31),Carry_level2(114),Sum_level2(114));
	
	L2_HA8 : ha port map(Input_PP9(36), Input_PP10(34),Carry_level2(115),Sum_level2(115));
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

	L6_FA7 : fa port map(Carry_level5(54), Sum_level5(55), Input_PP17(29), Carry_level6(57), Sum_level6(57));

	L6_FA8 : fa port map(Carry_level5(55), Sum_level5(56), Input_PP17(30), Carry_level6(58), Sum_level6(58));

	L6_FA9 : fa port map(Carry_level5(56), Sum_level5(57), Input_PP17(31), Carry_level6(59), Sum_level6(59));

	L6_FA10 : fa port map(Carry_level5(57), Sum_level5(58), Input_PP17(32), Carry_level6(60), Sum_level6(60));

	L6_FA11 : fa port map(Carry_level5(58), Input_PP16(35), Input_PP17(33), Carry_level6(61), Sum_level6(61));

	-- OUT_RCA ----------------------------------------

	-- SUM OUT ----------------------------------------
	sum : process(SumEnable)
	begin
		if SumEnable = '1' then
			Output <= (others => '0');
		end if;
	end process sum;

end architecture RTL;
