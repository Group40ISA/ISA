library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----to have lower number of NOP, it 's possible to move the and related to target address in the stage of execution
-----in this way we 'll have only 2 NOP rather than 3

entity Hazard_detection_unit is
    port(
        rs1, rs2, rd_ID_EX, rd_EX_MEM          : in  std_logic_vector(4 downto 0);
        alu_src                                : in  std_logic;
        mem_write                              : in  std_logic;
        mem_read_ID_EX                         : in  std_logic;
        effective_branch                       : in  std_logic;
        rst                                    : in  std_logic;
        pc_enable                              : out std_logic;
        nop_injector_ID_EX, nop_injector_IF_ID : out std_logic
    );
end entity Hazard_detection_unit;

architecture RTL of Hazard_detection_unit is

begin
    hz : process(effective_branch, rst, rs1, rs2, rd_ID_EX, mem_read_ID_EX)
    begin
        if (rst = '1') then
            pc_enable          <= '0';
            nop_injector_ID_EX <= '0';
            nop_injector_IF_ID <= '0';
        else
            ------
            ----these code line operates on the beq/jump instructions         
            ------
            if (effective_branch = '1') then

                nop_injector_ID_EX <= '1';
                nop_injector_IF_ID <= '1';
            else
                nop_injector_ID_EX <= '0';
                nop_injector_IF_ID <= '0';
            end if;

            ------
            ----this code lines operates on the store instructions         
            ------        
            if (mem_read_ID_EX = '1') then
                --This control is used to recognize if the istruction is an not a I-type 
                --and in such case compare  both registers  
                if (alu_src = '0') then
                    if (rs1 = rd_ID_EX or rs2 = rd_ID_EX) then
                        nop_injector_ID_EX <= '1';
                        pc_enable          <= '1';
                    else
                        nop_injector_ID_EX <= '0';
                        pc_enable          <= '0';
                    end if;
                elsif (alu_src = '1') then --if the instruction is an I-type,control only rs1.
                    if (rs1 = rd_ID_EX) then
                        nop_injector_ID_EX <= '1';
                        pc_enable          <= '1';
                    else
                        nop_injector_ID_EX <= '0';
                        pc_enable          <= '0';
                    end if;
                end if;
            else
                --Normal condition.
                pc_enable <= '0';
            end if;

            ------
            ----these code line operates on store-word instruction         
            ------
            if (mem_write = '1') then
                if (rs2 = rd_ID_EX) then
                    nop_injector_ID_EX <= '1';
                    pc_enable          <= '1';
                elsif (rs2 = rd_EX_MEM) then
                    nop_injector_ID_EX <= '1';
                    pc_enable          <= '1';
                else
                    nop_injector_ID_EX <= '0';
                    pc_enable          <= '0';
                end if;
            else
                nop_injector_ID_EX <= '0';
                pc_enable          <= '0';
            end if;
        end if;
    end process hz;

end architecture RTL;
