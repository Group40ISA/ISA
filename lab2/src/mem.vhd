library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
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
		Output_PP5 : out std_logic_vector(10 downto 0)
		--Output_PP6  : out std_logic_vector(36 downto 0);
		--Output_PP7  : out std_logic_vector(36 downto 0);
		--Output_PP8  : out std_logic_vector(36 downto 0);
		--Output_PP9  : out std_logic_vector(36 downto 0);
		--Output_PP10 : out std_logic_vector(36 downto 0);
		--Output_PP11 : out std_logic_vector(36 downto 0);
		--Output_PP12 : out std_logic_vector(36 downto 0);
		--Output_PP13 : out std_logic_vector(36 downto 0);
		--Output_PP14 : out std_logic_vector(36 downto 0);
		--Output_PP15 : out std_logic_vector(36 downto 0);
		--Output_PP16 : out std_logic_vector(36 downto 0);
		--Output_PP17 : out std_logic_vector(36 downto 0)
	);
end entity mem;

architecture RTL of mem is
	type mem is array (0 to 4) of std_logic_vector(12 downto 0);
	signal ram_block : mem;
	signal OE_sig    : std_logic;
begin
	mem_proc : process(clk, rst)
		variable count : integer := 0;
	begin
		if rst = '0' then
			OE_sig    <= '0';
			ram_block <= (others => (others => '0'));
			count := 0;
		elsif clk'event and clk = '0' then
			if count = 0 then
				OE_sig <= '0';
				ram_block(count)        <= '0' & not (S) & S & S & S & Input_PP;
				ram_block(count + 1)(0) <= S;
				count                   := count + 1;
			elsif count = 3 then
				ram_block(count)(11 downto 2) <= not (S) & S & Input_PP;
				ram_block(count + 1)(0)       <= S;
				count                         := count + 1;
			elsif count = 4 then
				ram_block(count)(9 downto 2) <= Input_PP;
				OE_sig               <= '1';
				count := 0;
			else
				ram_block(count)(12 downto 2) <= '1' & not (S) & S & Input_PP;
				ram_block(count + 1)(0)       <= S;
				count                   := count + 1;
			end if;
		end if;
	end process mem_proc;
	
	Output_PP1 <= ram_block(0)(11 downto 0);
	Output_PP2 <= ram_block(1);
	Output_PP3 <= ram_block(2);
	Output_PP4 <= ram_block(3)(11 downto 0);
	Output_PP5 <= ram_block(4)(10 downto 0);
	OE <= OE_sig;
	
end architecture RTL;
