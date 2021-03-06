library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Forward_unit is
	port(
		rs_1, rs_2                                                   : in  std_logic_vector(4 downto 0);
		rd_ex_mem, rd_mem_wb                                         : in  std_logic_vector(4 downto 0);
		reg_wrt_id_ex, reg_wrt_ex_mem, reg_wrt_mem_wb, branch_EX_MEM : in  std_logic;
		mem_read_EX_MEM                                              : in  std_logic;
		alu_src                                                      : in  std_logic;
		wb_sel_mux_ex_mem                                            : in  std_logic_vector(1 downto 0);
		rst                                                          : in  std_logic;
		rs_if_id, rd_id_ex                                           : in  std_logic_vector(4 downto 0);
		imm_ctrl                                                     : out std_logic_vector(1 downto 0);
		forward_A, forward_B                                         : out std_logic_vector(1 downto 0) --signals useful to select the correct bypassing
	);
end entity Forward_unit;

architecture RTL of Forward_unit is
	------
	--the data dependencies are verified up to two consecutive clock edges, because of that the comparisons are performed between
	--the signals out of RF and the siganls out of ex_mem reg and mem_wb reg   
	------ 
begin
	process(rst, rs_1, rs_2, rd_ex_mem, rd_mem_wb, alu_src, reg_wrt_ex_mem, reg_wrt_id_ex, reg_wrt_mem_wb, wb_sel_mux_ex_mem, rs_if_id, mem_read_EX_MEM, rd_id_ex, branch_EX_MEM)
	begin
		if (rst = '1') then
			forward_A <= "00";
			forward_B <= "00";
			imm_ctrl  <= "00";
		elsif (reg_wrt_ex_mem = '1' or reg_wrt_mem_wb = '1' or reg_wrt_id_ex = '1') then
			if (branch_EX_MEM = '0') then
				if (rs_1 = rd_ex_mem) then
					if (wb_sel_mux_ex_mem = "11") then
						forward_A <= "11"; ---AUIPC way
					elsif (wb_sel_mux_ex_mem = "00" or wb_sel_mux_ex_mem = "01") then
						forward_A <= "01"; ---ALU way
					else
						forward_A <= "00";
					end if;
				elsif (rs_1 = rd_mem_wb) then
					forward_A <= "10";  ---OUT MEM MUX way
				else
					forward_A <= "00";  ---READ 1 way 
				end if;
			else
				forward_A <= "00";      --READ 1 way
			end if;

			----
			--in case of alu_src=1, so when we are dealing with I type instruction we do not have to verify if there are 
			--hazard on rs2
			----

			if (alu_src = '0') then
				if (rs_2 = rd_ex_mem) then
					if (wb_sel_mux_ex_mem = "11") then
						forward_B <= "11"; ---AUIPC way
					elsif (wb_sel_mux_ex_mem = "00") then
						forward_B <= "01"; ---ALU way
					else
						forward_B <= "00";
					end if;
				elsif (rs_2 = rd_mem_wb) then
					forward_B <= "10";  ---OUT MEM MUX way
				else
					forward_B <= "00";  ---READ 1 way 
				end if;
			else
				forward_B <= "00";
			end if;

			----
			-- manage the control signal for the multiplexer which switches 
			-- the correct msb in input to the imm_gen
			----

			if (rs_if_id = rd_id_ex) then
				imm_ctrl <= "01";       --select the msb of alu result in the id/ex phase.
			elsif (rs_if_id = rd_ex_mem) then
				if(mem_read_EX_MEM = '1')then
					imm_ctrl  <= "11"; --select the msb of the output of memory
				else
					imm_ctrl <= "10";       --select the msb of alu in the ex/mem phase.
				end if;
			else
				imm_ctrl <= "00";       -- select the msb of the register file's out.
			end if;
		else
			forward_A <= "00";
			forward_B <= "00";
			imm_ctrl  <= "00";
		end if;
	end process;

end architecture RTL;
