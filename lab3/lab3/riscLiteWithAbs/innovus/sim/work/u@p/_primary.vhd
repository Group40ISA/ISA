library verilog;
use verilog.vl_types.all;
entity uP is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        instruction     : in     vl_logic_vector(31 downto 0);
        data            : in     vl_logic_vector(31 downto 0);
        pc              : out    vl_logic_vector(31 downto 0);
        out_rf          : out    vl_logic_vector(31 downto 0);
        alu_result      : out    vl_logic_vector(31 downto 0);
        data_mem_read   : out    vl_logic;
        data_mem_write  : out    vl_logic;
        pipe_stall      : out    vl_logic;
        pipe_flush1     : out    vl_logic;
        pipe_flush2     : out    vl_logic
    );
end uP;
