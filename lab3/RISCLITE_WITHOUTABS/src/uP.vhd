LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uP IS
    PORT(
        clk                                  : IN  STD_LOGIC;
        rst                                  : IN  STD_LOGIC;
        instruction                          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        data                                 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc                                   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_rf                               : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result                           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_mem_read                        : OUT STD_LOGIC;
        data_mem_write                       : OUT STD_LOGIC;
        pipe_stall, pipe_flush1, pipe_flush2 : OUT std_logic
    );
END ENTITY uP;

ARCHITECTURE structural OF uP IS
    COMPONENT ALU
        PORT(
            A, B    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            AluCtrl : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            zero    : OUT STD_LOGIC;
            result  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT ALU;

    component CU
        port(
            opcode          : in  std_logic_vector(6 downto 0);
            Branch          : out std_logic;
            MemRead         : out std_logic;
            MemToReg        : out std_logic;
            AluOp           : out std_logic_vector(1 downto 0);
            MemWrite        : out std_logic;
            AluSrc          : out std_logic;
            Lui_ctrl        : out std_logic;
            RegWrite        : out std_logic;
            write_back_ctrl : out std_logic
        );
    end component CU;

    COMPONENT AluControl
        PORT(
            AluOp     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            add_AluOp : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            AluCtrl   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT AluControl;

    COMPONENT RegisterFile
        PORT(
            clk      : IN  STD_LOGIC;
            rst      : IN  STD_LOGIC;
            RReg1    : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            RReg2    : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            WReg     : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            WData    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RegWrite : IN  STD_LOGIC;
            Read1    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Read2    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT RegisterFile;

    COMPONENT ImmGen
        PORT(
            instr : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            imm   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT ImmGen;

    component ForwardUnit
        port(
            rs_1, rs_2                     : IN  std_logic_vector(4 DOWNTO 0);
            rd_ex_mem, rd_mem_wb           : IN  std_logic_vector(4 DOWNTO 0);
            reg_wrt_ex_mem, reg_wrt_mem_wb : IN  std_logic;
            alu_src                        : IN  std_logic;
            wb_sel_mux_ex_mem              : IN  std_logic_vector(1 DOWNTO 0);
            rst                            : IN  std_logic;
            forward_A, forward_B           : OUT std_logic_vector(1 DOWNTO 0)
        );
    end component ForwardUnit;

    component HazardDetectionUnit
        port(
            rs1, rs2, rd_ID_EX, rd_EX_MEM        : in  std_logic_vector(4 downto 0);
            alu_src                              : in  std_logic;
            mem_write                            : in  std_logic;
            mem_read                             : in  std_logic;
            effective_branch                     : in  std_logic;
            rst                                  : in  std_logic;
            pipe_flush1, pipe_flush2, pipe_stall : out std_logic
        );
    end component HazardDetectionUnit;

    ----------------------------------------------------------
    ---------------------CU SIGNALs---------------------------
    SIGNAL branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, write_back_ctrl : STD_LOGIC;
    SIGNAL alu_op                                                                       : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL JAL_signal, Lui_ctrl                                                         : STD_LOGIC;
    ----------------------------------------------------------
    -------------------ALU_CTRL SIGNALs-----------------------
    SIGNAL alu_ctrl                                                                     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL Forward_A, Forward_B                                                         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    ----------------------------------------------------------
    -------------------ALU SIGNALs----------------------------
    SIGNAL zero                                                                         : STD_LOGIC;
    SIGNAL alu_result_signal, alu_input_A, alu_input_B                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ----------------------------------------------------------
    -------------------RF SIGNALs-----------------------------
    SIGNAL read1, read2                                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL out_writeback_mux                                                            : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_input_lui                                                                : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_input                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL out_mem_mux                                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    ----------------------------------------------------------------------
    --------------------BRANCH SIGNALS------------------------------------
    SIGNAL pc_jump, pc_next, mux_to_pc                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_int                                                                       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL effective_branch                                                             : STD_LOGIC;
    SIGNAL four_byte                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pipe_flush2_sig, pipe_flush1_sig, pipe_stall_sig                             : std_logic;
    ----------------------------------------------------------------------
    -------------------PIPE SIGNAL STAGE IF/ID----------------------------
    SIGNAL pc_int_IF_ID, instruction_IF_ID, pc_next_IF_ID                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --------------------------------------------------------------------
    -----------------PIPE SIGNAL STAGE ID/EX----------------------------
    SIGNAL branch_ID_EX, mem_read_ID_EX, mem_to_reg_ID_EX, mem_write_ID_EX              : STD_LOGIC;
    SIGNAL alu_src_ID_EX, reg_write_ID_EX, write_back_ctrl_ID_EX, Lui_ctrl_ID_EX        : STD_LOGIC;
    SIGNAL rs_1, rs_2                                                                   : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL alu_op_ID_EX                                                                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_int_ID_EX                                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read1_ID_EX, read2_ID_EX                                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL immediate_ID_EX                                                              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WReg_ID_EX                                                                   : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL add_AluOpCtrl_ID_EX                                                          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL pc_next_ID_EX                                                                : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -----------------------------------------------------------------------------
    -------------------PIPE SIGNAL STAGE EX/MEM----------------------------------
    SIGNAL pc_jump_EX_MEM                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL branch_EX_MEM, mem_read_EX_MEM, mem_to_reg_EX_MEM, mem_write_EX_MEM          : STD_LOGIC;
    SIGNAL write_back_ctrl_EX_MEM, reg_write_EX_MEM                                     : STD_LOGIC;
    SIGNAL pc_next_EX_MEM                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_result_signal_EX_MEM                                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read2_EX_MEM                                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WReg_EX_MEM                                                                  : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL wb_sel_mux_EX_MEM                                                            : STD_LOGIC_VECTOR(1 DOWNTO 0);
    ------------------------------------------------------------------------------- 
    -------------------PIPE SIGNAL STAGE WRITE BACK--------------------------------
    SIGNAL pc_jump_MEM_WB                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL JAL_signal_MEM_WB                                                            : STD_LOGIC;
    SIGNAL wb_sel_mux_MEM_WB                                                            : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_result_signal_MEM_WB                                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_next_MEM_WB                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WReg_MEM_WB                                                                  : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL reg_write_MEM_WB                                                             : STD_LOGIC;
    SIGNAL data_MEM_WB                                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    -----------------------------------------------------------------------------------------
    ------------------------------------FETCH STAGE------------------------------------------

    four_byte <= (2 => '1', OTHERS => '0');
    pc_next   <= STD_LOGIC_VECTOR(unsigned(pc_int) + unsigned(four_byte));
    WITH (effective_branch) SELECT mux_to_pc <=
        pc_jump WHEN '1',
        pc_next WHEN OTHERS;

    ProgramCounter : PROCESS(clk, rst)
    BEGIN
        IF (rst = '0') THEN
            pc_int <= STD_LOGIC_VECTOR(to_unsigned(4194304, 32));
        ELSIF (clk'event AND clk = '1') THEN
            if (pipe_stall_sig = '1') then
                --In case of some hazards or branches,the program counter
                -- needed to be stopped and save the previous address.
                pc_int <= pc_int;
            else
                pc_int <= mux_to_pc;
            end if;
        END IF;
    END PROCESS ProgramCounter;
    pc <= pc_int;

    -----------------------------------------------------------------------------------------
    ------------------------------------INSTRUCTION DECODE-----------------------------------
    IF_ID : PROCESS(clk, rst)
    BEGIN
        IF (rst = '0') THEN
            pc_int_IF_ID      <= (OTHERS => '0');
            instruction_IF_ID <= (OTHERS => '0');
            pc_next_IF_ID     <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            IF (pipe_flush2_sig = '1') then
                --If the jump is verified a nop is inserted in the register
                pc_int_IF_ID      <= (OTHERS => '0');
                instruction_IF_ID <= "00000000000000000000000000010011";
                pc_next_IF_ID     <= (OTHERS => '0');
            ELSif (pipe_stall_sig = '1') then
                -- If the store-word hazard or load-word hazard
                -- is verified the register save the precedent contenet.
                pc_int_IF_ID      <= pc_int_IF_ID;
                instruction_IF_ID <= instruction_IF_ID;
                pc_next_IF_ID     <= pc_next_IF_ID;
            else
                pc_int_IF_ID      <= pc_int;
                instruction_IF_ID <= instruction;
                pc_next_IF_ID     <= pc_next;
            END IF;
        END IF;
    END PROCESS;

    imm : ImmGen
        PORT MAP(
            instr => instruction_IF_ID,
            imm   => immediate
        );
    RF : RegisterFile
        PORT MAP(
            clk      => clk,
            rst      => rst,
            RReg1    => instruction_IF_ID(19 DOWNTO 15),
            RReg2    => instruction_IF_ID(24 DOWNTO 20),
            WReg     => WReg_MEM_WB,
            WData    => out_writeback_mux,
            RegWrite => reg_write_MEM_WB,
            Read1    => read1,
            Read2    => read2
        );

    cu_op : CU
        PORT MAP(
            opcode          => instruction_IF_ID(6 DOWNTO 0),
            Branch          => branch,
            MemRead         => mem_read,
            MemToReg        => mem_to_reg,
            AluOp           => alu_op,
            MemWrite        => mem_write,
            AluSrc          => alu_src,
            Lui_ctrl        => Lui_ctrl,
            RegWrite        => reg_write,
            write_back_ctrl => write_back_ctrl
        );

    hzd_unit : HazardDetectionUnit
        port map(
            rs1              => instruction_IF_ID(19 DOWNTO 15),
            rs2              => instruction_IF_ID(24 DOWNTO 20),
            rd_ID_EX         => WReg_ID_EX,
            rd_EX_MEM        => WReg_EX_MEM,
            alu_src          => alu_src,
            mem_write        => mem_write_ID_EX,
            mem_read         => mem_read_ID_EX,
            effective_branch => effective_branch,
            rst              => rst,
            pipe_flush1      => pipe_flush1_sig,
            pipe_flush2      => pipe_flush2_sig,
            pipe_stall       => pipe_stall_sig
        );
    pipe_flush1 <= pipe_flush1_sig;
    pipe_flush2 <= pipe_flush2_sig;
    pipe_stall  <= pipe_stall_sig;
    ----------------------------------------------------------------------------------------
    --------------------------------EXECUTION STAGE-----------------------------------------
    ID_EX : PROCESS(clk, rst)
    BEGIN
        IF (rst = '0') THEN
            branch_ID_EX          <= '0';
            mem_read_ID_EX        <= '0';
            mem_to_reg_ID_EX      <= '0';
            mem_write_ID_EX       <= '0';
            alu_src_ID_EX         <= '0';
            Lui_ctrl_ID_EX        <= '0';
            reg_write_ID_EX       <= '0';
            write_back_ctrl_ID_EX <= '0';
            alu_op_ID_EX          <= "00";
            pc_int_ID_EX          <= (OTHERS => '0');
            read1_ID_EX           <= (OTHERS => '0');
            read2_ID_EX           <= (OTHERS => '0');
            immediate_ID_EX       <= (OTHERS => '0');
            rs_1                  <= (OTHERS => '0');
            rs_2                  <= (OTHERS => '0');
            WReg_ID_EX            <= (OTHERS => '0');
            add_AluOpCtrl_ID_EX   <= (OTHERS => '0');
            pc_next_ID_EX         <= (OTHERS => '0');
        ELSIF (clk'event and clk = '1') THEN
            IF (pipe_flush1_sig = '1') THEN
                --In case of hazards or branchs verified,a nop insertion is needed. 
                branch_ID_EX          <= '0';
                mem_read_ID_EX        <= '0';
                mem_to_reg_ID_EX      <= '0';
                mem_write_ID_EX       <= '0';
                alu_src_ID_EX         <= '1';
                Lui_ctrl_ID_EX        <= '0';
                reg_write_ID_EX       <= '1';
                write_back_ctrl_ID_EX <= '0';
                pc_next_ID_EX         <= (others => '0');
                alu_op_ID_EX          <= (others => '0');
                pc_int_ID_EX          <= (others => '0');
                read1_ID_EX           <= (others => '0');
                read2_ID_EX           <= (others => '0');
                immediate_ID_EX       <= (others => '0');
                rs_1                  <= (others => '0');
                rs_2                  <= (others => '0');
                WReg_ID_EX            <= (others => '0');
                add_AluOpCtrl_ID_EX   <= "0011";
            else
                branch_ID_EX          <= branch;
                mem_read_ID_EX        <= mem_read;
                mem_to_reg_ID_EX      <= mem_to_reg;
                mem_write_ID_EX       <= mem_write;
                alu_src_ID_EX         <= alu_src;
                Lui_ctrl_ID_EX        <= Lui_ctrl;
                reg_write_ID_EX       <= reg_write;
                write_back_ctrl_ID_EX <= write_back_ctrl;
                pc_next_ID_EX         <= pc_next_IF_ID;
                alu_op_ID_EX          <= alu_op;
                pc_int_ID_EX          <= pc_int_IF_ID;
                read1_ID_EX           <= read1;
                read2_ID_EX           <= read2;
                immediate_ID_EX       <= immediate;
                rs_1                  <= instruction_IF_ID(19 DOWNTO 15);
                rs_2                  <= instruction_IF_ID(24 DOWNTO 20);
                WReg_ID_EX            <= instruction_IF_ID(11 DOWNTO 7);
                add_AluOpCtrl_ID_EX   <= instruction_IF_ID(30) & instruction_IF_ID(14 DOWNTO 12);
            END IF;
        END IF;
    END PROCESS;

    pc_jump          <= STD_LOGIC_VECTOR(signed(pc_int_ID_EX) + signed(immediate_ID_EX));
    effective_branch <= branch_ID_EX and zero;

    aluctrl : AluControl
        PORT MAP(
            AluOp     => alu_op_ID_EX,
            add_AluOp => add_AluOpCtrl_ID_EX,
            AluCtrl   => alu_ctrl
        );

    WITH Lui_ctrl_ID_EX SELECT alu_input_lui <=
        read1_ID_EX WHEN '0',
        (OTHERS => '0') WHEN '1',
        read1_ID_EX WHEN OTHERS;

    WITH alu_src_ID_EX SELECT alu_input <=
        immediate_ID_EX WHEN '1',
        read2_ID_EX WHEN OTHERS;

    WITH Forward_A SELECT alu_input_A <=
        alu_input_lui WHEN "00",
        alu_result_signal_EX_MEM WHEN "01",
        out_mem_mux WHEN "10",
        pc_jump_EX_MEM WHEN "11",
        (OTHERS => 'U') WHEN OTHERS;

    WITH Forward_B SELECT alu_input_B <=
        alu_input WHEN "00",
        alu_result_signal_EX_MEM WHEN "01",
        out_mem_mux WHEN "10",
        pc_jump_EX_MEM WHEN "11",
        (OTHERS => 'U') WHEN OTHERS;

    op : ALU
        PORT MAP(
            A       => alu_input_A,
            B       => alu_input_B,
            AluCtrl => alu_ctrl,
            zero    => zero,
            result  => alu_result_signal
        );

    forward : ForwardUnit
        PORT map(
            rs_1              => rs_1,
            rs_2              => rs_2,
            rd_ex_mem         => WReg_EX_MEM,
            rd_mem_wb         => WReg_MEM_WB,
            reg_wrt_ex_mem    => reg_write_EX_MEM,
            reg_wrt_mem_wb    => reg_write_MEM_WB,
            alu_src           => alu_src_ID_EX,
            wb_sel_mux_ex_mem => wb_sel_mux_EX_MEM,
            rst               => rst,
            forward_A         => Forward_A,
            forward_B         => Forward_B
        );

    EX_MEM : PROCESS(clk, rst)
    BEGIN
        IF (rst = '0') THEN
            pc_jump_EX_MEM           <= (OTHERS => '0');
            branch_EX_MEM            <= '0';
            mem_read_EX_MEM          <= '0';
            mem_to_reg_EX_MEM        <= '0';
            mem_write_EX_MEM         <= '0';
            write_back_ctrl_EX_MEM   <= '0';
            reg_write_EX_MEM         <= '0';
            pc_next_EX_MEM           <= (OTHERS => '0');
            alu_result_signal_EX_MEM <= (OTHERS => '0');
            read2_EX_MEM             <= (OTHERS => '0');
            WReg_EX_MEM              <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            pc_jump_EX_MEM           <= pc_jump;
            branch_EX_MEM            <= branch_ID_EX;
            mem_read_EX_MEM          <= mem_read_ID_EX;
            mem_to_reg_EX_MEM        <= mem_to_reg_ID_EX;
            mem_write_EX_MEM         <= mem_write_ID_EX;
            write_back_ctrl_EX_MEM   <= write_back_ctrl_ID_EX;
            reg_write_EX_MEM         <= reg_write_ID_EX;
            pc_next_EX_MEM           <= pc_next_ID_EX;
            alu_result_signal_EX_MEM <= alu_result_signal;
            read2_EX_MEM             <= read2_ID_EX;
            WReg_EX_MEM              <= WReg_ID_EX;
            --        ELSE
            --           pc_jump_EX_MEM           <= pc_jump_EX_MEM;
            --          branch_EX_MEM            <= branch_EX_MEM;
            --            mem_read_EX_MEM          <= mem_read_EX_MEM;
            --          mem_to_reg_EX_MEM        <= mem_to_reg_EX_MEM;
            --         mem_write_EX_MEM         <= mem_write_EX_MEM;
            --          write_back_ctrl_EX_MEM   <= write_back_ctrl_EX_MEM;
            --           reg_write_EX_MEM         <= reg_write_EX_MEM;
            --           pc_next_EX_MEM           <= pc_next_EX_MEM;
            --          alu_result_signal_EX_MEM <= alu_result_signal_EX_MEM;
            --          read2_EX_MEM             <= read2_EX_MEM;
            --          WReg_EX_MEM              <= WReg_EX_MEM;
        END IF;
        --        END IF;
    END PROCESS;

    ----------------------------------------------------------------------------------------
    ------------------------------ MEMORIZATION STAGE---------------------------------------
    JAL_signal        <= branch_EX_MEM AND reg_write_EX_MEM;
    alu_result        <= alu_result_signal_EX_MEM;
    out_rf            <= read2_EX_MEM;
    data_mem_read     <= mem_read_EX_MEM;
    data_mem_write    <= mem_write_EX_MEM;
    wb_sel_mux_EX_MEM <= mem_to_reg_EX_MEM & write_back_ctrl_EX_MEM;

    MEM_WB : PROCESS(clk, rst)
    BEGIN
        IF (rst = '0') THEN
            pc_jump_MEM_WB           <= (OTHERS => '0');
            JAL_signal_MEM_WB        <= '0';
            wb_sel_mux_MEM_WB        <= "00";
            alu_result_signal_MEM_WB <= (OTHERS => '0');
            pc_next_MEM_WB           <= (OTHERS => '0');
            WReg_MEM_WB              <= (OTHERS => '0');
            reg_write_MEM_WB         <= '0';
            data_MEM_WB              <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            pc_jump_MEM_WB           <= pc_jump_EX_MEM;
            JAL_signal_MEM_WB        <= JAL_signal;
            wb_sel_mux_MEM_WB        <= wb_sel_mux_EX_MEM;
            alu_result_signal_MEM_WB <= alu_result_signal_EX_MEM;
            pc_next_MEM_WB           <= pc_next_EX_MEM;
            WReg_MEM_WB              <= WReg_EX_MEM;
            reg_write_MEM_WB         <= reg_write_EX_MEM;
            data_MEM_WB              <= data;
            -- ELSE
            --       pc_jump_MEM_WB           <= pc_jump_MEM_WB;
            --        JAL_signal_MEM_WB        <= JAL_signal_MEM_WB;
            --         wb_sel_mux_MEM_WB        <= wb_sel_mux_MEM_WB;
            --         alu_result_signal_MEM_WB <= alu_result_signal_MEM_WB;
            --         pc_next_MEM_WB           <= pc_next_MEM_WB;
            --          WReg_MEM_WB              <= WReg_MEM_WB;
            --          reg_write_MEM_WB         <= reg_write_MEM_WB;
            --          data_MEM_WB              <= data_MEM_WB;
        END IF;
    END PROCESS;

    -------------------------------------------------------------------------------------------------
    ----------------------------------WRITE BACK STAGE-----------------------------------------------
    WITH wb_sel_mux_MEM_WB SELECT out_mem_mux <=
        data_MEM_WB WHEN "10",          --select the out of memory       
        pc_jump_MEM_WB WHEN "11",       --select the AUIPC way
        alu_result_signal_MEM_WB WHEN "00" | "01", --select the alu way or lui way
        data_MEM_WB WHEN OTHERS;

    WITH (JAL_signal_MEM_WB) SELECT out_writeback_mux <=
        pc_next_MEM_WB WHEN '1',
        out_mem_mux WHEN OTHERS;

END ARCHITECTURE structural;
