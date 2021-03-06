LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_uP IS
END ENTITY tb_uP;

ARCHITECTURE rtl OF tb_uP IS

    component uP
        port(
            clk                  : IN  STD_LOGIC;
            rst                  : IN  STD_LOGIC;
            instruction          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            data                 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc                   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_rf               : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_result           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_mem_read        : OUT STD_LOGIC;
            data_mem_write       : OUT STD_LOGIC;
            pipe_stall,pipe_flush1,pipe_flush2 : out std_logic
        );
    end component uP;

    component textMemory
        generic(
            address_parallelism     : INTEGER;
            instruction_parallelism : INTEGER
        );
        port(clk,rst : in std_logic;
            address     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
            init        : IN  STD_LOGIC;
            end_code    : OUT STD_LOGIC;
            instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
            pipe_stall,pipe_flush1,pipe_flush2 : in std_logic
        );
    end component textMemory;

    component dataMemory
        generic(
            address_parallelism : INTEGER;
            data_parallelism    : INTEGER
        );
        port(
            init                        : IN  STD_LOGIC;
            input_data                  : IN  STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
            address                     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
            end_code, read_en, write_en : IN  STD_LOGIC;
            output_data                 : OUT STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0)
        );
    end component dataMemory;
    
    component clk_gen is
    port(
        END_SIM : in  std_logic;
        clk     : out std_logic;
        rst   : out std_logic;
        init    : out std_logic
    );
end component clk_gen;

    SIGNAL clk, rst, data_mem_read, data_mem_write       : STD_LOGIC;
    SIGNAL instruction, data, pc_sig, out_rf, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL end_code, init                         : STD_LOGIC;
    signal pipe_stall,pipe_flush1,pipe_flush2 : std_logic;

BEGIN

    risc_lite : uP
        PORT MAP(
            clk => clk,
            rst => rst,
            instruction => instruction,
            data => data,
            pc => pc_sig,
            out_rf => out_rf,
            alu_result => alu_result,
            data_mem_read => data_mem_read,
            data_mem_write => data_mem_write,
            pipe_stall => pipe_stall,
            pipe_flush1 => pipe_flush1,
            pipe_flush2 => pipe_flush2);

    instr_mem : textMemory
        GENERIC MAP(
            address_parallelism     => 32,
            instruction_parallelism => 32)
        PORT MAP(clk => clk,
            rst => rst,
            address     => pc_sig,
            init        => init,
            end_code    => end_code,
            instruction => instruction,
            pipe_stall => pipe_stall,
            pipe_flush1 => pipe_flush1,
            pipe_flush2 => pipe_flush2 );

    data_mem : dataMemory
        GENERIC MAP(
            address_parallelism => 32,
            data_parallelism    => 32)
        PORT MAP(
            init        => init,
            input_data  => out_rf,
            address     => alu_result,
            end_code    => end_code,
            read_en     => data_mem_read,
            write_en    => data_mem_write,
            output_data => data
        );

    clock_gen: clk_gen port map(
        END_SIM => end_code,
        clk     => clk,
        rst     => rst,
        init    => init
    );


END ARCHITECTURE rtl;
