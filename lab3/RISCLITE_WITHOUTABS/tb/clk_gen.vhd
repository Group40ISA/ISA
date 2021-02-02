library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_gen is
    port(
        END_SIM : in  std_logic;
        clk     : out std_logic;
        rst   : out std_logic;
        init    : out std_logic
    );
end entity clk_gen;

architecture RTL of clk_gen is

    signal clk_i : std_logic;

begin

    clk_proc : process
        constant Ts : time := 2 ns;
    begin
        if (clk_i = 'U') then
            clk_i <= '0';
        else
            clk_i <= not (clk_i);
        end if;
        wait for Ts / 2;
    end process;

    clk <= clk_i and not (END_SIM);

    rst_proc : process
        constant Ts : time := 2 ns;
    begin
        rst <= '0';
        init <= '1';
        wait for 3 * Ts / 2;
        rst <= '1';
        init <= '0';
        wait;
    end process;

end architecture RTL;
