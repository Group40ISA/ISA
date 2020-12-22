--------------------------------------------------------------------------------
--  Data_memory which writes the data in a file at the end of the execution   --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY data_memory IS
    GENERIC (
        address_parallelism : INTEGER := 32;
        data_parallelism : INTEGER := 32;
        memory_depth : INTEGER := 5);
    PORT ( clk : in std_logic;
        init : IN STD_LOGIC;
        input_data : IN STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
        address : IN STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        end_code, read_en, write_en : IN STD_LOGIC;
        output_data : OUT STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0)
    );
END ENTITY data_memory;

ARCHITECTURE rtl OF data_memory IS

    FILE text_content : text;

    TYPE memory IS ARRAY ((2 ** memory_depth) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(data_parallelism - 1 DOWNTO 0);
    SIGNAL data_mem : memory;

BEGIN

    proc_out : PROCESS (end_code)
        VARIABLE out_data_line : line;
        VARIABLE out_pointer : INTEGER := 0; -- variable that points at successive lines of the memory for every written line
    BEGIN
        file_open(text_content, "C:\Users\39373\Documents\Uni\Magistrale\IntegratedSystemArchitecture\Labs\ISA\lab3\tb\memory\content_data.txt", write_mode);

        IF end_code = '1' THEN
            WHILE (out_pointer < 2 ** memory_depth) LOOP
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

    read_write_proc : PROCESS (init, write_en, read_en, addres, clks)
    BEGIN
        IF init = '1' THEN
            data_mem <= (OTHERS => (OTHERS => '0'));
        elsIF clk'event and clk = '0' then
         if write_en = '1' THEN
            data_mem(to_integer(unsigned(address))) <= input_data;
         end if;
        end if;
        
        IF read_en = '1' THEN
            output_data <= data_mem(to_integer(unsigned(address)));
        END IF;
    END PROCESS read_write_proc;

END ARCHITECTURE rtl;