library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_text_mem is
end entity tb_text_mem;

architecture rtl of tb_text_mem is
    signal address : std_logic_vector(4 downto 0);
    signal init,end_code : std_logic;
    signal instruction : std_logic_vector(31 downto 0);

    component text_memory IS
    GENERIC (
        address_parallelism : INTEGER := 6;
        instruction_parallelism : INTEGER := 32);
    PORT (
        address : IN STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        init : IN STD_LOGIC;
        end_code : in std_logic;
        instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
    );
    END component text_memory;

begin
    
    code_mem: text_memory generic map(5,32)
                          port map(address, init, end_code, instruction);

    stimuli: process
    begin
        init <= '0';
        end_code <= '0';
        address <= "00000";
        wait for 1 ns;
        init <= '1';
        wait for 1 ns;
        init <= '0';
        wait for 1 ns;
        address <= "00001";
        wait for 1 ns;
        address <= "01100";
        end_code <= '1';
        wait;
    end process stimuli;
    
    
end architecture rtl;