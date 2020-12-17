library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uP is
    port(
        clk            : in  std_logic;
        rst            : in  std_logic;
        instruction    : in  std_logic_vector(31 downto 0);
        data           : in  std_logic_vector(31 downto 0);
        pc             : out std_logic_vector(31 downto 0);
        out_rf         : out std_logic_vector(31 downto 0);
        alu_result     : out std_logic_vector(31 downto 0);
        data_mem_read  : out std_logic;
        data_mem_write : out std_logic
    );
end entity uP;

architecture structural of uP is
    component ALU
        port(
            A, B    : in  std_logic_vector(31 downto 0);
            AluCtrl : in  std_logic_vector(3 downto 0);
            zero    : out std_logic;
            result  : out std_logic_vector(31 downto 0)
        );
    end component ALU;

    component CU
        port(
            opcode          : in  std_logic_vector(6 downto 0);
            Branch          : out std_logic;
            MemRead         : out std_logic;
            MemToReg        : out std_logic;
            AluOp           : out std_logic_vector(1 downto 0);
            MemWrite        : out std_logic;
            AluSrc          : out std_logic;
            RegWrite        : out std_logic;
            write_back_ctrl : out std_logic
        );
    end component CU;

    component AluControl
        port(
            AluOp     : in  std_logic_vector(1 downto 0);
            add_AluOp : in  std_logic_vector(3 downto 0);
            AluCtrl   : out std_logic_vector(3 downto 0)
        );
    end component AluControl;

    component RegisterFile
        port(
            RReg1    : in  std_logic_vector(4 downto 0);
            RReg2    : in  std_logic_vector(4 downto 0);
            WReg     : in  std_logic_vector(4 downto 0);
            WData    : in  std_logic_vector(31 downto 0);
            RegWrite : in  std_logic;
            Read1    : out std_logic_vector(31 downto 0);
            Read2    : out std_logic_vector(31 downto 0)
        );
    end component RegisterFile;

    component Imm_Gen
        port(
            instr : in  std_logic_vector(31 downto 0);
            imm   : out std_logic_vector(31 downto 0)
        );
    end component Imm_Gen;

    ----------------------------------------------------------
    -------CU SIGNALs-----------------------------------------
    signal branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, write_back_ctrl : std_logic;
    signal alu_op                                                                       : std_logic_vector(1 downto 0);
    ----------------------------------------------------------
    -------------------ALU_CTRL SIGNALs-----------------------
    signal alu_ctrl                                                                     : std_logic_vector(3 downto 0);
    ----------------------------------------------------------
    -------------------ALU SIGNALs----------------------------
    signal zero                                                                         : std_logic;
    signal wb_sel_mux                                                                   : std_logic_vector(1 downto 0);
    ----------------------------------------------------------
    -------------------RF SIGNALs-----------------------------
    signal read1, read2                                                                 : std_logic_vector(31 downto 0);
    signal out_writeback_mux                                                            : std_logic_vector(31 downto 0);
    signal alu_input                                                                    : std_logic_vector(31 downto 0);
    signal immediate                                                                    : std_logic_vector(31 downto 0);
    signal out_mem_mux                                                                  : std_logic_vector(31 downto 0);

    --------------------BRANCH SIGNALS------------------------------------
    signal pc_jump, pc_int, pc_next, mux_to_pc : std_logic_vector(31 downto 0); -- vedere se vogliono farloda 32 o 5
    signal four_byte                           : std_logic_vector(31 downto 0);

begin

    pc                     <= pc_int;
    four_byte(31 downto 5) <= (others => '0');
    four_byte(4 downto 0)  <= "10000";

    process(clk, rst)
    begin
        if (rst = '1') then
            pc_int <= (others => '0');
        elsif (clk'event and clk = '1') then
            pc_int <= mux_to_pc;
        end if;
    end process;

    pc_next <= std_logic_vector(unsigned(pc_int) + unsigned(four_byte));
    pc_jump <= std_logic_vector(unsigned(pc_int) + unsigned(immediate));

    with (branch and zero) select mux_to_pc <=
        pc_jump when '1',
        pc_next when others;
    --------------------------------------------------------------------------------------------------------
    imm : Imm_Gen
        port map(
            instr => instruction,
            imm   => immediate
        );
    RF : RegisterFile
        port map(
            RReg1    => instruction(19 downto 15),
            RReg2    => instruction(24 downto 20),
            WReg     => instruction(11 downto 7),
            WData    => out_writeback_mux,
            RegWrite => reg_write,
            Read1    => read1,
            Read2    => read2
        );
    out_rf <= read2;

    with alu_src select alu_input <=
        read2 when '0',
        immediate when '1';
    -------------------------------------------------------------------------------------------------------
    cu_op : CU
        port map(
            opcode          => instruction(6 downto 0),
            Branch          => branch,
            MemRead         => mem_read,
            MemToReg        => mem_to_reg,
            AluOp           => alu_op,
            MemWrite        => mem_write,
            AluSrc          => alu_src,
            RegWrite        => reg_write,
            write_back_ctrl => write_back_ctrl
        );
    data_mem_read  <= mem_read;
    data_mem_write <= mem_write;

    -------------------------------------------------------------------------------------------------------
    aluctrl : AluControl
        port map(
            AluOp     => alu_op,
            add_AluOp => instruction(30) & instruction(14 downto 12),
            AluCtrl   => alu_ctrl
        );

    op : ALU
        port map(
            A       => read1,
            B       => alu_input,
            AluCtrl => alu_ctrl,
            zero    => zero,
            result  => alu_result
        );

    wb_sel_mux <= mem_to_reg & write_back_ctrl;

    with wb_sel_mux select out_mem_mux <=
        data when "10",                 --select the out of memory
        pc_jump when "11",              --select the AUIPC way
        alu_result when "00",           --select the alu way
        immediate when "01";            --select the LUI way

    with (branch and reg_write) select out_writeback_mux <=
        pc_jump when '1',
        out_mem_mux when others;

end architecture structural;
