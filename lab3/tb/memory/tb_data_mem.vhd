library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_data_mem is
end entity tb_data_mem;

architecture rtl of tb_data_mem is
    signal address : std_logic_vector(4 downto 0);
    signal end_code, read_en, write_en, init : std_logic;
    signal input_data, output_data : std_logic_vector(31 downto 0);

    component data_memory IS
    GENERIC (
        address_parallelism : INTEGER := 6;
        data_parallelism : INTEGER := 32);
    PORT (init : std_logic;
        input_data : IN STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
        address : IN STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        end_code, read_en, write_en : in std_logic;
        output_data : OUT STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0)
    );
    END component data_memory;

begin
    
    code_mem: data_memory generic map(5,32)
                          port map(init ,input_data ,address, end_code, read_en, write_en, output_data);

    stimuli: process
    begin
        init <= '0';
        wait for 1 ns;
        init <= '1';
        end_code <= '0';
        read_en <= '0';
        write_en <= '0';
        wait for 1 ns;
        init <= '0';
        write_en <= '1';
        address <= "00000";
        input_data <= std_logic_vector(to_signed(32,32));
        wait for 1 ns;
        address <= "00001";
        input_data <= std_logic_vector(to_signed(15,32));
        wait for 1 ns;
        end_code <= '1';
        wait;
    end process stimuli;
    
    
end architecture rtl;