LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_uP IS
END ENTITY tb_uP;

ARCHITECTURE rtl OF tb_uP IS

    COMPONENT uP IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_rf : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_mem_read : OUT STD_LOGIC;
            data_mem_write : OUT STD_LOGIC
        );
    END COMPONENT uP;

    COMPONENT text_memory IS
        GENERIC (
            address_parallelism : INTEGER := 32;
            instruction_parallelism : INTEGER := 32;
            memory_depth : integer := 5);
        PORT (
            address : IN STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
            init : IN STD_LOGIC;
            end_code : IN STD_LOGIC;
            instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
        );
    END COMPONENT text_memory;

    component data_memory
        generic(
            address_parallelism : INTEGER;
            data_parallelism    : INTEGER;
            memory_depth        : INTEGER
        );
        port( clk : in  std_logic;
            init                        : IN  STD_LOGIC;
            input_data                  : IN  STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
            address                     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
            end_code, read_en, write_en : IN  STD_LOGIC;
            output_data                 : OUT STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0)
        );
    end component data_memory;

    SIGNAL clk, rst, data_mem_read, data_mem_write : STD_LOGIC;
    SIGNAL instruction, data, pc_sig, out_rf, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL end_code, init : STD_LOGIC;

BEGIN

    risc_lite : uP PORT MAP(
        clk => clk,
        rst => rst,
        instruction => instruction,
        data => data,
        pc => pc_sig,
        out_rf => out_rf,
        alu_result => alu_result,
        data_mem_read => data_mem_read,
        data_mem_write => data_mem_write);

    instr_mem : text_memory GENERIC MAP(
        address_parallelism => 32,
        instruction_parallelism => 32,
        memory_depth => 5)
    PORT MAP(
        address => pc_sig,
        init => init,
        end_code => end_code,
        instruction => instruction);

    data_mem : data_memory GENERIC MAP(
        address_parallelism => 32,
        data_parallelism => 32,
        memory_depth => 5
    )
    PORT MAP(clk => clk;
        init => init,
        input_data => out_rf,
        address => alu_result,
        end_code => end_code,
        read_en => data_mem_read,
        write_en => data_mem_write,
        output_data => data
    );

    clk_proc: process
    begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process clk_proc;

    stimuli: process
    begin
        end_code <= '0';
        rst  <= '1';
        init <= '1';
        wait for 100 ps;
        rst  <= '0';
        init <= '0';
        wait for 4 ns;
        end_code <= '1';
        wait for 1 ns;
        end_code <= '1';
        wait;
    end process stimuli;

END ARCHITECTURE rtl;