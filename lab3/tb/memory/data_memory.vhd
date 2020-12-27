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
        data_parallelism    : INTEGER := 32;
        memory_depth        : INTEGER := 5);
    PORT(
        clk                         : IN  STD_LOGIC;
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
    BEGIN
        file_open(text_content, "/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/lab3/tb/content_data.txt", write_mode);

        IF end_code = '1' THEN
            WHILE (out_pointer < 268505089) LOOP
                write(out_data_line, to_integer(signed(data_mem(out_pointer))));
                writeline(text_content, out_data_line);
                out_pointer := out_pointer + 1;
            END LOOP;
        END IF;
        file_close(text_content);
    END PROCESS proc_out;

    --------------------------------------------------------------------------------
    --  process to have a transparent read/write data_memory                      --
    --------------------------------------------------------------------------------

    init_process : PROCESS(init)
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer  : INTEGER := 268500992; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr   : STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
    BEGIN
        IF init = '1' THEN
            file_open(text_file,"/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/lab3/tb/memory/data.txt", read_mode);
            WHILE NOT (endfile(text_file)) AND init_pointer < 268505088 LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                data_mem(init_pointer)     <= value_instr(31 downto 24);
                data_mem(init_pointer + 1) <= value_instr(23 downto 16);
                data_mem(init_pointer + 2) <= value_instr(15 downto 8);
                data_mem(init_pointer + 3) <= value_instr(7 downto 0);
                init_pointer               := init_pointer + 4;
            END LOOP;
            WHILE init_pointer < 268505088 LOOP
                data_mem(init_pointer)     <= (OTHERS => '0');
                data_mem(init_pointer + 1) <= (OTHERS => '0');
                data_mem(init_pointer + 2) <= (OTHERS => '0');
                data_mem(init_pointer + 3) <= (OTHERS => '0');
                init_pointer               := init_pointer + 4;
            END LOOP;
            file_close(text_file);
        END IF;
    END PROCESS init_process;

    PROCESS(write_en, address, input_data)
    begin
        IF write_en = '1' and init = '0' THEN
            if to_integer(unsigned(address)) >= 268500992 then --CONTROLLO PRE-PIPELINE
                data_mem(to_integer(unsigned(address)))     <= input_data(31 downto 24);
                data_mem(to_integer(unsigned(address)) + 1) <= input_data(23 downto 16);
                data_mem(to_integer(unsigned(address)) + 2) <= input_data(15 downto 8);
                data_mem(to_integer(unsigned(address)) + 3) <= input_data(7 downto 0);
            end if;
        else
            data_mem <= data_mem;
        end if;
    end process;
    PROCESS(read_en, address, data_mem)
    begin
        IF read_en = '1' and init = '0' THEN
            if to_integer(unsigned(address)) >= 268500992 then --CONTROLLO PRE-PIPELINE
                output_data(31 downto 24) <= data_mem(to_integer(unsigned(address)));
                output_data(23 downto 16) <= data_mem(to_integer(unsigned(address)) + 1);
                output_data(15 downto 8)  <= data_mem(to_integer(unsigned(address)) + 2);
                output_data(7 downto 0)   <= data_mem(to_integer(unsigned(address)) + 3);
            END IF;
        END IF;

    end process;
END ARCHITECTURE rtl;
