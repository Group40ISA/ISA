library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MBEX1 is
	port(
		x           : in  std_logic_vector(2 downto 0);
		A           : in  std_logic_vector(31 downto 0);
		S           : out std_logic;
		Output_PP   : out std_logic_vector(32 downto 0)
	);
end entity MBEX1;

architecture RTL of MBEX1 is

	component NotBlock is
		port(
			A              : in  std_logic_vector(32 downto 0);
			NotEnable      : in  std_logic;
			PartialProduct : out std_logic_vector(32 downto 0)
		);
	end component NotBlock;
	signal OutMBE_Mux : std_logic_vector(32 downto 0);
	signal zero       : std_logic_vector(32 downto 0);

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

MBEt: MBE_tab port map(x,MuxSel,NotEn);

zero <= (others => '0');
	with MuxSel select OutMBE_Mux <=
		zero when "00",
		A(31) & A when "01",
	    A & '0' when "10",
	    zero when others;

Ppout: NotBlock port map(OutMBE_Mux,NotEn,Output_PP);

S <= NotEn;


end architecture RTL;
