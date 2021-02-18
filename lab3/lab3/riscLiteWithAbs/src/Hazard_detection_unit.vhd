library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----to have lower number of NOP, it 's possible to move the AND related to target address in the stage of execution
-----in this way we 'll have only 2 NOP rather than 3

entity Hazard_detection_unit is
    port(
        rs1, rs2, rd_ID_EX, rd_EX_MEM        : in  std_logic_vector(4 downto 0);
        alu_src                              : in  std_logic;
        mem_write                            : in  std_logic;
        mem_read                             : in  std_logic;
        effective_branch                     : in  std_logic; -- signal useful to indicate the jump condition
        rst                                  : in  std_logic;
        pipe_flush1, pipe_flush2, pipe_stall : out std_logic -- signal useful to insert the NOP operation into the pipe
    );
end entity Hazard_detection_unit;

architecture RTL of Hazard_detection_unit is

begin
    hz : process(effective_branch, rst, rs1, rs2, rd_ID_EX, rd_EX_MEM, mem_read, mem_write, alu_src)
    begin
        if (rst = '1') then
            pipe_flush1 <= '0';
            pipe_flush2 <= '0';
            pipe_stall  <= '0';
        -----
        ----these code lines operates on the store instructions         
        ------ 
        elsif (mem_read = '1') then
            if (rs1 = rd_ID_EX or rs2 = rd_ID_EX) then
                pipe_stall  <= '1';
                pipe_flush1 <= '1';     --ID/EX
		pipe_flush2 <= '0';
            else
                pipe_stall  <= '0';
                pipe_flush1 <= '0';
		pipe_flush2 <= '0';
            end if;
        ------
        ----these code lines operates on the load instructions         
        ------          
        elsif (mem_write = '1') then
            if (rs2 = rd_ID_EX) then
                pipe_stall  <= '1';
                pipe_flush1 <= '1';     --ID/EX 
		pipe_flush2 <= '0';
            else
                if (rs2 = rd_EX_MEM) then
                    pipe_stall  <= '1';
                    pipe_flush1 <= '1';
		    pipe_flush2 <= '0';
                else
                    pipe_stall  <= '0';
                    pipe_flush1 <= '0';
		    pipe_flush2 <= '0';
                end if;
            end if;
        ------
        ----these code line operates on the beq/jump instructions         
        ------
        elsif (effective_branch = '1') then
            pipe_flush1 <= '1';
            pipe_flush2 <= '1';
            pipe_stall  <= '0';
        else
            pipe_flush1 <= '0';
            pipe_flush2 <= '0';
            pipe_stall  <= '0';
        end if;
    end process hz;

end architecture RTL;
