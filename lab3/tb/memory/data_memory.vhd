--------------------------------------------------------------------------------
--  Data_memory which writes the data in a file at the end of the execution   --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY data_memory IS
    GENERIC(
        address_parallelism : INTEGER := 32;
        data_parallelism    : INTEGER := 32);
    PORT(
        init                        : IN  STD_LOGIC;
        input_data                  : IN  STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
        address                     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        end_code, read_en, write_en : IN  STD_LOGIC;
        output_data                 : OUT STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0)
    );
END ENTITY data_memory;

ARCHITECTURE rtl OF data_memory IS

    FILE text_content : text;
    FILE text_file    : TEXT;

    TYPE memory IS ARRAY (268505088 DOWNTO 268500992) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_mem : memory;

BEGIN

    proc_out : PROCESS(end_code)
        VARIABLE out_data_line : line;
        VARIABLE out_pointer   : INTEGER := 268500992;
        variable in_text       : std_logic_vector(31 downto 0);
        variable mem_text      : memory;
    BEGIN
        IF end_code = '1' and end_code'event THEN
            mem_text := data_mem;
            file_open(text_content, "/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/ISA/lab3/tb/memory/content_data.txt", append_mode);

            WHILE (out_pointer < 268505088) LOOP
                in_text     := mem_text(out_pointer) & mem_text((out_pointer + 1)) & mem_text((out_pointer + 2)) & mem_text((out_pointer + 3));
                --                in_text(31 downto 24) := mem_text(out_pointer);
                --                in_text(23 downto 16) := mem_text((out_pointer + 1));
                --                in_text(15 downto 8)  := mem_text((out_pointer + 2));
                --                in_text(7 downto 0)   := mem_text((out_pointer + 3));
                write(out_data_line, in_text, right);
                writeline(text_content, out_data_line);
                out_pointer := out_pointer + 4;
            END LOOP;
            file_close(text_content);

        END IF;
    END PROCESS proc_out;

    --------------------------------------------------------------------------------
    --  process to have a transparent read/write data_memory                      --
    --------------------------------------------------------------------------------

    init_proc : PROCESS(init, address, input_data, write_en) -- @suppress 
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer  : INTEGER := 268500992; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr   : STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
    BEGIN
        IF init = '1' THEN
            file_open(text_file, "/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/ISA/lab3/tb/memory/data.txt", read_mode);
            WHILE NOT (endfile(text_file)) and init_pointer < 268505088 LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                data_mem(init_pointer)     <= value_instr(31 downto 24);
                data_mem(init_pointer + 1) <= value_instr(23 downto 16);
                data_mem(init_pointer + 2) <= value_instr(15 downto 8);
                data_mem(init_pointer + 3) <= value_instr(7 downto 0);
                init_pointer               := init_pointer + 4;
            END LOOP;
            file_close(text_file);
        ELSIF write_en = '1' AND to_integer(unsigned(address)) >= 268500992 THEN
            data_mem(to_integer(unsigned(address)))     <= input_data(31 downto 24);
            data_mem(to_integer(unsigned(address)) + 1) <= input_data(23 downto 16);
            data_mem(to_integer(unsigned(address)) + 2) <= input_data(15 downto 8);
            data_mem(to_integer(unsigned(address)) + 3) <= input_data(7 downto 0);
        else
            data_mem <= data_mem;
        end if;

    end process init_proc;

    process(read_en, address) --@suppress
    begin
        IF read_en = '1' and init = '0' and to_integer(unsigned(address)) >= 268500992 THEN
            output_data(31 downto 24) <= data_mem(to_integer(unsigned(address)));
            output_data(23 downto 16) <= data_mem(to_integer(unsigned(address)) + 1);
            output_data(15 downto 8)  <= data_mem(to_integer(unsigned(address)) + 2);
            output_data(7 downto 0)   <= data_mem(to_integer(unsigned(address)) + 3);
        END IF;
    end process;

END ARCHITECTURE rtl;
