library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PartialProductGen is
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;
		x          : in  std_logic_vector(7 downto 0);
		A          : in  std_logic_vector(7 downto 0);
		OE         : out  std_logic;
		Output_PP1 : out std_logic_vector(11 downto 0);
		Output_PP2 : out std_logic_vector(12 downto 0);
		Output_PP3 : out std_logic_vector(12 downto 0);
		Output_PP4 : out std_logic_vector(11 downto 0);
		Output_PP5 : out std_logic_vector(10 downto 0)
	);
end entity PartialProductGen;

architecture RTL of PartialProductGen is

	component mem is
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			S          : in  std_logic;
			Input_PP   : in  std_logic_vector(7 downto 0);
			OE         : out std_logic;
			Output_PP1 : out std_logic_vector(11 downto 0);
			Output_PP2 : out std_logic_vector(12 downto 0);
			Output_PP3 : out std_logic_vector(12 downto 0);
			Output_PP4 : out std_logic_vector(11 downto 0);
			Output_PP5 : out std_logic_vector(10 downto 0));
	end component mem;
	signal OE_sig   : std_logic;
	component shift is
		generic(parallelism : integer := 7);
		port(
			clk : in  std_logic;
			rst : in  std_logic;
			D   : in  std_logic_vector(parallelism - 1 downto 0);
			Q   : out std_logic_vector(2 downto 0)
		);
	end component shift;
	signal inputMBE : std_logic_vector(2 downto 0);

	signal A_tmp : std_logic_vector(7 downto 0);
	signal A_int : std_logic_vector(7 downto 0);

	component NotBlock is
		port(
			A              : in  std_logic_vector(7 downto 0);
			NotEnable      : in  std_logic;
			PartialProduct : out std_logic_vector(7 downto 0)
		);
	end component NotBlock;
	signal OutMBE_Mux : std_logic_vector(7 downto 0);
	signal zero       : std_logic_vector(7 downto 0);
	signal pp         : std_logic_vector(7 downto 0);

	component MBE_tab is
		port(
			Input      : in  std_logic_vector(2 downto 0);
			Mux_Select : out std_logic_vector(1 downto 0);
			NotEnable  : out std_logic
		);
	end component MBE_tab;
	signal MuxSel : std_logic_vector(1 downto 0);
	signal NotEn  : std_logic;
begin

	A_register : process(clk, rst)
	begin
		if rst = '0' then
			A_tmp <= (others => '0');
		elsif clk'event and clk = '1' then
			A_tmp <= A;
		end if;
	end process;
	A_int <= A_tmp;

	zero <= (others => '0');
	with MuxSel select OutMBE_Mux <=
		zero when "00",
		A_int when "01",
	    A_int(6 downto 0) & '0' when "10",
	    zero when others;

	x_reg : shift
		generic map(parallelism => 8)
		port map(
			clk => clk,
			rst => rst,
			D   => x,
			Q   => inputMBE
		);

	mbetab : MBE_tab
		port map(
			Input      => inputMBE,
			Mux_Select => MuxSel,
			NotEnable  => NotEn
		);

	notbl : NotBlock
		port map(
			A              => OutMBE_Mux,
			NotEnable      => NotEn,
			PartialProduct => pp
		);

	mem_pp : mem
		port map(
			clk        => clk,
			rst        => rst,
			S          => NotEn,
			Input_PP   => pp,
			OE         => OE_sig,
			Output_PP1 => Output_PP1,
			Output_PP2 => Output_PP2,
			Output_PP3 => Output_PP3,
			Output_PP4 => Output_PP4,
			Output_PP5 => Output_PP5
		);

end architecture RTL;
