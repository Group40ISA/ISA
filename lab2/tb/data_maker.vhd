library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is
  port (
    CLK  : in  std_logic;
    RST_n: in std_logic;
    DATA : out std_logic_vector(31 downto 0);
    VOUT : out std_logic;
    END_SIM: out std_logic);
end data_maker;

architecture beh of data_maker is
	
	signal sEndSim : std_logic;
  	signal END_SIM_i : std_logic_vector(0 to 15); 

begin  -- beh

  process (CLK)
    file fp : text open read_mode is "../sim/fp_samples.hex";
    variable ptr : line;
    variable val : std_logic_vector(31 downto 0);
  begin  -- process
    if CLK'event and CLK = '1' then  -- rising clock edge
      if (not(endfile(fp))) then
	VOUT <= '1';
        readline(fp, ptr);
        hread(ptr, val);        
	else
	VOUT <= '0';
	val:=(others=>'0'); --after tco;        
	sEndSim <= '1';-- after tco;
      end if;
      DATA <= val;
    end if;
  end process;

 process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0');-- after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim;-- after tco;
      END_SIM_i(1 to 15) <= END_SIM_i(0 to 14);-- after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(15);  

end beh;
