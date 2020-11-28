library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul is
    port(x : in std_logic_vector(31 downto 0);
        A : in std_logic_vector(31 downto 0);
        p : out std_logic_vector(63 downto 0));
end entity mul;

architecture rtl of mul is

    component MBEX17 is
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
    end component MBEX17;

    type array_type is array (0 to 16) of std_logic_vector(36 downto 0);
    signal Output_PP : array_type;

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
		    Product     : out std_logic_vector(63 downto 0)
	);
end component adder;

begin
    
MBE_UNIT: MBEX17 port map(x,A,Output_PP(0)(35 downto 0),Output_PP(1),Output_PP(2),Output_PP(3),Output_PP(4),Output_PP(5),Output_PP(6),Output_PP(7),
                            Output_PP(8),Output_PP(9),Output_PP(10),Output_PP(11),Output_PP(12),Output_PP(13),Output_PP(14),Output_PP(15)(35 downto 0),
                                Output_PP(16)(33 downto 0));

DADDATREE: adder port map(Output_PP(0)(35 downto 0),Output_PP(1),Output_PP(2),Output_PP(3),Output_PP(4),Output_PP(5),Output_PP(6),Output_PP(7),
                            Output_PP(8),Output_PP(9),Output_PP(10),Output_PP(11),Output_PP(12),Output_PP(13),Output_PP(14),Output_PP(15)(35 downto 0),
                                Output_PP(16)(33 downto 0),p);
    
    
end architecture rtl;