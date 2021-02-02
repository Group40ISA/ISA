library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ForwardUnit is
    port(
        rs_1, rs_2                     : in  std_logic_vector(4 downto 0);
        rd_ex_mem, rd_mem_wb           : in  std_logic_vector(4 downto 0);
        reg_wrt_ex_mem, reg_wrt_mem_wb : in  std_logic;
        alu_src                        : in  std_logic;
        wb_sel_mux_ex_mem              : in  std_logic_vector(1 downto 0);
        rst                            : in  std_logic;
        forward_A, forward_B           : out std_logic_vector(1 downto 0)
    );
end entity ForwardUnit;

architecture RTL of ForwardUnit is

begin
    process(rst, rs_1, rs_2, rd_ex_mem, rd_mem_wb, alu_src, reg_wrt_ex_mem, reg_wrt_mem_wb, wb_sel_mux_ex_mem)
    begin
        if (rst = '0') then
            forward_A <= "00";
            forward_B <= "00";
        elsif (reg_wrt_ex_mem = '1' or reg_wrt_mem_wb = '1') then

            if (rs_1 = rd_ex_mem) then
                if (wb_sel_mux_ex_mem = "11") then
                    forward_A <= "11";  ---AUIPC way
                elsif (wb_sel_mux_ex_mem = "00" or wb_sel_mux_ex_mem = "01") then
                    forward_A <= "01";  ---ALU way
                else
                    forward_A <= "00";
                end if;
            elsif (rs_1 = rd_mem_wb) then
                forward_A <= "10";      ---OUT MEM MUX way
            else
                forward_A <= "00";      ---READ 1 way 
            end if;

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
        else
            forward_A <= "00"; --CHANGE latch inferred otherwise
            forward_B <= "00";
        end if;
    end process;

end architecture RTL;
