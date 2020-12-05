LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MBEX17 IS
    PORT (
        x : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        Output_PP1 : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
        Output_PP2 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP3 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP4 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP5 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP6 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP7 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP8 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP9 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP10 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP11 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP12 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP13 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP14 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP15 : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
        Output_PP16 : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
        Output_PP17 : OUT STD_LOGIC_VECTOR(33 DOWNTO 0)
    );
END ENTITY MBEX17;

ARCHITECTURE rtl OF MBEX17 IS

    TYPE array_type IS ARRAY (0 TO 16) OF STD_LOGIC_VECTOR(32 DOWNTO 0);
    SIGNAL Output_PP : array_type;
    SIGNAL S : STD_LOGIC_VECTOR(16 DOWNTO 0);

    COMPONENT MBEX1 IS
        PORT (
            x : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            S : OUT STD_LOGIC;
            Output_PP : OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
        );
    END COMPONENT MBEX1;

    SIGNAL x_ext : STD_LOGIC_VECTOR(34 DOWNTO 0);

BEGIN

    x_ext <= "00" & x & '0';

    MBE : FOR I IN 0 TO 16 GENERATE
        MBE_I : MBEX1 PORT MAP(x_ext((I * 2) + 2 DOWNTO I * 2), A, S(I), Output_PP(I));
    END GENERATE MBE;

    Output_PP1 <= NOT(S(0)) & S(0) & S(0) & Output_PP(0);
    Output_PP2 <= '1' & NOT(S(1)) & Output_PP(1) & '0' & S(0);
    Output_PP3 <= '1' & NOT(S(2)) & Output_PP(2) & '0' & S(1);
    Output_PP4 <= '1' & NOT(S(3)) & Output_PP(3) & '0' & S(2);
    Output_PP5 <= '1' & NOT(S(4)) & Output_PP(4) & '0' & S(3);
    Output_PP6 <= '1' & NOT(S(5)) & Output_PP(5) & '0' & S(4);
    Output_PP7 <= '1' & NOT(S(6)) & Output_PP(6) & '0' & S(5);
    Output_PP8 <= '1' & NOT(S(7)) & Output_PP(7) & '0' & S(6);
    Output_PP9 <= '1' & NOT(S(8)) & Output_PP(8) & '0' & S(7);
    Output_PP10 <= '1' & NOT(S(9)) & Output_PP(9) & '0' & S(8);
    Output_PP11 <= '1' & NOT(S(10)) & Output_PP(10) & '0' & S(9);
    Output_PP12 <= '1' & NOT(S(11)) & Output_PP(11) & '0' & S(10);
    Output_PP13 <= '1' & NOT(S(12)) & Output_PP(12) & '0' & S(11);
    Output_PP14 <= '1' & NOT(S(13)) & Output_PP(13) & '0' & S(12);
    Output_PP15 <= '1' & NOT(S(14)) & Output_PP(14) & '0' & S(13);
    Output_PP16 <= NOT(S(15)) & Output_PP(15) & '0' & S(14);
    Output_PP17 <= Output_PP(16)(31 DOWNTO 0) & '0' & S(15);
END ARCHITECTURE rtl;