LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uP IS
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
END ENTITY uP;

ARCHITECTURE structural OF uP IS
    COMPONENT ALU
        PORT (
            A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            AluCtrl : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            zero : OUT STD_LOGIC;
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT ALU;

    COMPONENT CU
        PORT (
            opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
            Branch : OUT STD_LOGIC;
            MemRead : OUT STD_LOGIC;
            MemToReg : OUT STD_LOGIC;
            AluOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            MemWrite : OUT STD_LOGIC;
            AluSrc : OUT STD_LOGIC;
            RegWrite : OUT STD_LOGIC;
            write_back_ctrl : OUT STD_LOGIC
        );
    END COMPONENT CU;

    COMPONENT AluControl
        PORT (
            AluOp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            add_AluOp : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            AluCtrl : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT AluControl;

    COMPONENT RegisterFile
        PORT (rst : in std_logic;
            RReg1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            RReg2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            WReg : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            WData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            RegWrite : IN STD_LOGIC;
            Read1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Read2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT RegisterFile;

    COMPONENT Imm_Gen
        PORT (
            instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT Imm_Gen;

    ----------------------------------------------------------
    -------CU SIGNALs-----------------------------------------
    SIGNAL branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, write_back_ctrl : STD_LOGIC;
    SIGNAL alu_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
    ----------------------------------------------------------
    -------------------ALU_CTRL SIGNALs-----------------------
    SIGNAL alu_ctrl : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL add_AluOpCtrl : STD_LOGIC_VECTOR(3 DOWNTO 0);
    ----------------------------------------------------------
    -------------------ALU SIGNALs----------------------------
    SIGNAL zero : STD_LOGIC;
    SIGNAL wb_sel_mux : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_result_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ----------------------------------------------------------
    -------------------RF SIGNALs-----------------------------
    SIGNAL read1, read2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL out_writeback_mux : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_input : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL out_mem_mux : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --------------------BRANCH SIGNALS------------------------------------
    SIGNAL pc_jump, pc_int, pc_next, mux_to_pc : STD_LOGIC_VECTOR(31 DOWNTO 0); -- vedere se vogliono farloda 32 o 5
    SIGNAL four_byte : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    pc <= pc_int;
    --four_byte <= (5 downto 0 => "100000" ,OTHERS => '0');
    four_byte <= (0 => '1', OTHERS => '0');
    --four_byte(4 DOWNTO 0) <= "10000";

    PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            pc_int <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            pc_int <= mux_to_pc;
        END IF;
    END PROCESS;

    pc_next <= STD_LOGIC_VECTOR(unsigned(pc_int) + unsigned(four_byte));
    pc_jump <= STD_LOGIC_VECTOR(unsigned(pc_int) + unsigned(immediate));

    WITH (branch AND zero) SELECT mux_to_pc <=
    pc_jump WHEN '1',
    pc_next WHEN OTHERS;
    --------------------------------------------------------------------------------------------------------
    imm : Imm_Gen
    PORT MAP(
        instr => instruction,
        imm => immediate
    );
    RF : RegisterFile
    PORT MAP(rst => rst,
        RReg1 => instruction(19 DOWNTO 15),
        RReg2 => instruction(24 DOWNTO 20),
        WReg => instruction(11 DOWNTO 7),
        WData => out_writeback_mux,
        RegWrite => reg_write,
        Read1 => read1,
        Read2 => read2
    );
    out_rf <= read2;

    WITH alu_src SELECT alu_input <=
        immediate WHEN '1',
        read2 WHEN OTHERS;
    -------------------------------------------------------------------------------------------------------
    cu_op : CU
    PORT MAP(
        opcode => instruction(6 DOWNTO 0),
        Branch => branch,
        MemRead => mem_read,
        MemToReg => mem_to_reg,
        AluOp => alu_op,
        MemWrite => mem_write,
        AluSrc => alu_src,
        RegWrite => reg_write,
        write_back_ctrl => write_back_ctrl
    );
    data_mem_read <= mem_read;
    data_mem_write <= mem_write;

    -------------------------------------------------------------------------------------------------------
    aluctrl : AluControl
    PORT MAP(
        AluOp => alu_op,
        add_AluOp => add_AluOpCtrl,
        AluCtrl => alu_ctrl
    );

    add_AluOpctrl <= instruction(30) & instruction(14 DOWNTO 12);

    op : ALU
    PORT MAP(
        A => read1,
        B => alu_input,
        AluCtrl => alu_ctrl,
        zero => zero,
        result => alu_result_signal
    );

    alu_result <= alu_result_signal;

    wb_sel_mux <= mem_to_reg & write_back_ctrl;

    WITH wb_sel_mux SELECT out_mem_mux <=
        data WHEN "10", --select the out of memory
        pc_jump WHEN "11", --select the AUIPC way
        alu_result_signal WHEN "00", --select the alu way
        immediate WHEN "01", --select the LUI way
        data WHEN OTHERS;

    WITH (branch AND reg_write) SELECT out_writeback_mux <=
    pc_jump WHEN '1',
    out_mem_mux WHEN OTHERS;

END ARCHITECTURE structural;