library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MBEX17 is
    port(
        x : in std_logic_vector(31 downto 0);
        A : in std_logic_vector(31 downto 0);
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
end entity MBEX17;

architecture rtl of MBEX17 is
    
    type array_type is array (0 to 16) of std_logic_vector(32 downto 0);
    signal Output_PP : array_type;
    signal S : std_logic_vector(16 downto 0);

    component MBEX1 is
        port(
            x           : in  std_logic_vector(2 downto 0);
            A           : in  std_logic_vector(31 downto 0);
            S           : out std_logic;
            Output_PP   : out std_logic_vector(32 downto 0)
        );
    end component MBEX1;

    signal x_ext : std_logic_vector(34 downto 0);
        
begin
        
x_ext <= "00" & x & '0';

MBE: for I in 0 to 16 generate
    MBE_I: MBEX1 port map (x_ext( (I*2) + 2 downto I*2), A, S(I), Output_PP(I) );
end generate MBE;

Output_PP1  <= not(S(0)) & S(0) & S(0) &  Output_PP(0);
Output_PP2  <= '1' & not(S(1))  & Output_PP(1) & '0' & S(0);
Output_PP3  <= '1' & not(S(2))  & Output_PP(2) & '0' & S(1);
Output_PP4  <= '1' & not(S(3))  & Output_PP(3) & '0' & S(2);
Output_PP5  <= '1' & not(S(4))  & Output_PP(4) & '0' & S(3);
Output_PP6  <= '1' & not(S(5))  & Output_PP(5) & '0' & S(4);
Output_PP7  <= '1' & not(S(6))  & Output_PP(6) & '0' & S(5);
Output_PP8  <= '1' & not(S(7))  & Output_PP(7) & '0' & S(6);
Output_PP9  <= '1' & not(S(8))  & Output_PP(8) & '0' & S(7);
Output_PP10 <= '1' & not(S(9))  & Output_PP(9) & '0' & S(8);
Output_PP11 <= '1' & not(S(10))  & Output_PP(10) & '0' & S(9);
Output_PP12 <= '1' & not(S(11))  & Output_PP(11) & '0' & S(10);
Output_PP13 <= '1' & not(S(12))  & Output_PP(12) & '0' & S(11);
Output_PP14 <= '1' & not(S(13))  & Output_PP(13)  & '0' & S(12);
Output_PP15 <= '1' & not(S(14))  & Output_PP(14) & '0' & S(13);
Output_PP16 <= not(S(15))  & Output_PP(15) & '0' & S(14);
Output_PP17 <= Output_PP(16)(31 downto 0) & '0' & S(15);
        
        
end architecture rtl;