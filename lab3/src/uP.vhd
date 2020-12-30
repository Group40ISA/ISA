LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uP IS
	PORT(
		clk            : IN  STD_LOGIC;
		rst            : IN  STD_LOGIC;
		instruction    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc             : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		out_rf         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		alu_result     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_mem_read  : OUT STD_LOGIC;
		data_mem_write : OUT STD_LOGIC
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

	COMPONENT CU
		PORT(
			opcode          : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
			Branch          : OUT STD_LOGIC;
			MemRead         : OUT STD_LOGIC;
			MemToReg        : OUT STD_LOGIC;
			AluOp           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			MemWrite        : OUT STD_LOGIC;
			AluSrc          : OUT STD_LOGIC;
			RegWrite        : OUT STD_LOGIC;
			write_back_ctrl : OUT STD_LOGIC
		);
	END COMPONENT CU;

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

	COMPONENT Imm_Gen
		PORT(
			instr : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			imm   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT Imm_Gen;

	----------------------------------------------------------
	---------------------CU SIGNALs---------------------------
	SIGNAL branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, write_back_ctrl : STD_LOGIC;
	SIGNAL alu_op                                                                       : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL JAL_signal                                                                   : STD_LOGIC;
	----------------------------------------------------------
	-------------------ALU_CTRL SIGNALs-----------------------
	SIGNAL alu_ctrl                                                                     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	----------------------------------------------------------
	-------------------ALU SIGNALs----------------------------
	SIGNAL zero                                                                         : STD_LOGIC;
	SIGNAL wb_sel_mux                                                                   : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL alu_result_signal                                                            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	----------------------------------------------------------
	-------------------RF SIGNALs-----------------------------
	SIGNAL read1, read2                                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL out_writeback_mux                                                            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL alu_input                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL immediate                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL out_mem_mux                                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	----------------------------------------------------------------------
	--------------------BRANCH SIGNALS------------------------------------
	SIGNAL pc_jump, pc_next, mux_to_pc                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_int                                                                       : STD_LOGIC_VECTOR(31 DOWNTO 0); --:= STD_LOGIC_VECTOR(TO_UNSIGNED(4194304, 32));
	SIGNAL four_byte                                                                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	----------------------------------------------------------------------
	-------------------PIPE SIGNAL STAGE IF/ID----------------------------
	SIGNAL pc_int_IF_ID, instruction_IF_ID, pc_next_IF_ID                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--------------------------------------------------------------------
	-----------------PIPE SIGNAL STAGE ID/EX----------------------------
	SIGNAL branch_ID_EX, mem_read_ID_EX, mem_to_reg_ID_EX, mem_write_ID_EX              : STD_LOGIC;
	SIGNAL alu_src_ID_EX, reg_write_ID_EX, write_back_ctrl_ID_EX                        : STD_LOGIC;
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
	SIGNAL zero_EX_MEM                                                                  : STD_LOGIC;
	SIGNAL alu_result_signal_EX_MEM                                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read2_EX_MEM                                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WReg_EX_MEM                                                                  : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL immediate_EX_MEM                                                             : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------
	-------------------PIPE SIGNAL STAGE WRITE BACK--------------------------------
	SIGNAL pc_jump_MEM_WB                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL JAL_signal_MEM_WB                                                            : STD_LOGIC;
	SIGNAL mem_to_reg_MEM_WB                                                            : STD_LOGIC;
	SIGNAL write_back_ctrl_MEM_WB                                                       : STD_LOGIC;
	SIGNAL alu_result_signal_MEM_WB                                                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_next_MEM_WB                                                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WReg_MEM_WB                                                                  : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_write_MEM_WB                                                             : STD_LOGIC;
	SIGNAL data_MEM_WB                                                                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL immediate_MEM_WB                                                             : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	IF_ID : PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pc_int_IF_ID      <= (OTHERS => '0');
			instruction_IF_ID <= (OTHERS => '0');
			pc_next_IF_ID     <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			pc_int_IF_ID      <= pc_int;
			instruction_IF_ID <= instruction;
			pc_next_IF_ID     <= pc_next;
		END IF;
	END PROCESS;

	WITH (branch_EX_MEM AND zero_EX_MEM) SELECT mux_to_pc <=
		pc_jump_EX_MEM WHEN '1',
		pc_next WHEN OTHERS;

	pc        <= pc_int;
	four_byte <= (2 => '1', OTHERS => '0');

	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pc_int <= STD_LOGIC_VECTOR(to_unsigned(4194304, 32));
		ELSIF (clk'event AND clk = '1') THEN
			pc_int <= mux_to_pc;
		END IF;
	END PROCESS;

	pc_next <= STD_LOGIC_VECTOR(unsigned(pc_int) + unsigned(four_byte));

	--------------------------------------------------------------------------------------------------------
	------------------------------------INSTRUCTION DECODE--------------------------------------------------
	imm : Imm_Gen
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
			RegWrite        => reg_write,
			write_back_ctrl => write_back_ctrl
		);

	ID_EX : PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			branch_ID_EX          <= '0';
			mem_read_ID_EX        <= '0';
			mem_to_reg_ID_EX      <= '0';
			mem_write_ID_EX       <= '0';
			alu_src_ID_EX         <= '0';
			reg_write_ID_EX       <= '0';
			write_back_ctrl_ID_EX <= '0';
			alu_op_ID_EX          <= "00";
			pc_int_ID_EX          <= (OTHERS => '0');
			read1_ID_EX           <= (OTHERS => '0');
			read2_ID_EX           <= (OTHERS => '0');
			immediate_ID_EX       <= (OTHERS => '0');
			WReg_ID_EX            <= (OTHERS => '0');
			add_AluOpCtrl_ID_EX   <= (OTHERS => '0');
			pc_next_ID_EX         <= (OTHERS => '0');

		ELSIF (clk'event AND clk = '1') THEN
			branch_ID_EX          <= branch;
			mem_read_ID_EX        <= mem_read;
			mem_to_reg_ID_EX      <= mem_to_reg;
			mem_write_ID_EX       <= mem_write;
			alu_src_ID_EX         <= alu_src;
			reg_write_ID_EX       <= reg_write;
			write_back_ctrl_ID_EX <= write_back_ctrl;
			pc_next_ID_EX         <= pc_next_IF_ID;
			alu_op_ID_EX          <= alu_op;
			pc_int_ID_EX          <= pc_int_IF_ID;
			read1_ID_EX           <= read1;
			read2_ID_EX           <= read2;
			immediate_ID_EX       <= immediate;
			WReg_ID_EX            <= instruction_IF_ID(11 DOWNTO 7);
			add_AluOpCtrl_ID_EX   <= instruction_IF_ID(30) & instruction_IF_ID(14 DOWNTO 12);
		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------------------------------
	--------------------------EXECUTION STAGE--------------------------------------------------------------
	aluctrl : AluControl
		PORT MAP(
			AluOp     => alu_op_ID_EX,
			add_AluOp => add_AluOpCtrl_ID_EX,
			AluCtrl   => alu_ctrl
		);

	WITH alu_src_ID_EX SELECT alu_input <=
		immediate_ID_EX WHEN '1',
		read2_ID_EX WHEN OTHERS;

	op : ALU
		PORT MAP(
			A       => read1_ID_EX,
			B       => alu_input,
			AluCtrl => alu_ctrl,
			zero    => zero,
			result  => alu_result_signal
		);

	pc_jump <= STD_LOGIC_VECTOR(signed(pc_int_ID_EX) + signed(immediate_ID_EX));

	EX_MEM : PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pc_jump_EX_MEM           <= (OTHERS => '0');
			branch_EX_MEM            <= '0';
			mem_read_EX_MEM          <= '0';
			mem_to_reg_EX_MEM        <= '0';
			mem_write_EX_MEM         <= '0';
			write_back_ctrl_EX_MEM   <= '0';
			reg_write_EX_MEM         <= '0';
			pc_next_EX_MEM           <= (OTHERS => '0');
			zero_EX_MEM              <= '0';
			alu_result_signal_EX_MEM <= (OTHERS => '0');
			read2_EX_MEM             <= (OTHERS => '0');
			WReg_EX_MEM              <= (OTHERS => '0');
			immediate_EX_MEM         <= (OTHERS  => '0');

		ELSIF (clk'event AND clk = '1') THEN

			pc_jump_EX_MEM           <= pc_jump;
			branch_EX_MEM            <= branch_ID_EX;
			mem_read_EX_MEM          <= mem_read_ID_EX;
			mem_to_reg_EX_MEM        <= mem_to_reg_ID_EX;
			mem_write_EX_MEM         <= mem_write_ID_EX;
			write_back_ctrl_EX_MEM   <= write_back_ctrl_ID_EX;
			reg_write_EX_MEM         <= reg_write_ID_EX;
			pc_next_EX_MEM           <= pc_next_ID_EX;
			zero_EX_MEM              <= zero;
			alu_result_signal_EX_MEM <= alu_result_signal;
			read2_EX_MEM             <= read2_ID_EX;
			WReg_EX_MEM              <= WReg_ID_EX;
			immediate_EX_MEM         <= immediate_ID_EX;

		END IF;
	END PROCESS;
	-------------------------------------------------------------------------------------------------------
	------------------------------ MEMORIZATION STAGE------------------------------------------------------
	JAL_signal     <= branch_EX_MEM AND reg_write_EX_MEM;
	alu_result     <= alu_result_signal_EX_MEM;
	out_rf         <= read2_EX_MEM;
	data_mem_read  <= mem_read_EX_MEM;
	data_mem_write <= mem_write_EX_MEM;

	MEM_WB : PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pc_jump_MEM_WB           <= (OTHERS => '0');
			JAL_signal_MEM_WB        <= '0';
			mem_to_reg_MEM_WB        <= '0';
			write_back_ctrl_MEM_WB   <= '0';
			alu_result_signal_MEM_WB <= (OTHERS => '0');
			pc_next_MEM_WB           <= (OTHERS => '0');
            immediate_MEM_WB         <= (OTHERS => '0');
			WReg_MEM_WB              <= (OTHERS => '0');
			reg_write_MEM_WB         <= '0';
			data_MEM_WB              <= (OTHERS  => '0');

		ELSIF (clk'event AND clk = '1') THEN
			pc_jump_MEM_WB           <= pc_jump_EX_MEM;
			JAL_signal_MEM_WB        <= JAL_signal;
			mem_to_reg_MEM_WB        <= mem_to_reg_EX_MEM;
			write_back_ctrl_MEM_WB   <= write_back_ctrl_EX_MEM;
			alu_result_signal_MEM_WB <= alu_result_signal_EX_MEM;
			pc_next_MEM_WB           <= pc_next_EX_MEM;
			immediate_MEM_WB         <= immediate_EX_MEM;
			WReg_MEM_WB              <= WReg_EX_MEM;
			reg_write_MEM_WB         <= reg_write_EX_MEM;
			data_MEM_WB              <= data;

		END IF;
	END PROCESS;
	
	-------------------------------------------------------------------------------------------------
	----------------------------------WRITE BACK STAGE-----------------------------------------------
    wb_sel_mux <= mem_to_reg_MEM_WB & write_back_ctrl_MEM_WB;

    WITH wb_sel_mux SELECT out_mem_mux <=
	        data_MEM_WB WHEN "10", --select the out of memory       
	        pc_jump_MEM_WB WHEN "11", --select the AUIPC way
	        alu_result_signal_MEM_WB WHEN "00", --select the alu way
	        immediate_MEM_WB WHEN "01", --select the LUI way
	        data_MEM_WB WHEN OTHERS;
   
    WITH (JAL_signal_MEM_WB) SELECT out_writeback_mux <=
		pc_next_MEM_WB WHEN '1',
		out_mem_mux WHEN OTHERS; 
		
END ARCHITECTURE structural;
