--------------------------------------------------------------------------------
--  text_emory which takes initialisation content form a file.                --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY text_memory IS
    GENERIC (
        address_parallelism : INTEGER := 6;
        instruction_parallelism : INTEGER := 32);
    PORT (
        address : IN STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        init : IN STD_LOGIC;
        end_code : IN STD_LOGIC;
        instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
    );
END ENTITY text_memory;

ARCHITECTURE rtl OF text_memory IS

    FILE text_file : text;

    SIGNAL gated_address : STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
    SIGNAL init_ext : STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
    
    TYPE memory IS ARRAY (2 ** address_parallelism - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
    SIGNAL text_mem : memory;

BEGIN

    init_ext <= (OTHERS => init);
    gated_address <= address AND NOT(init_ext); -- when the memory is being initialized, it does not accept input address

    proc_init : PROCESS (init)
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer : INTEGER := 0; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr : STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
    BEGIN
        file_open(text_file, "C:\Users\39373\Documents\Uni\Magistrale\IntegratedSystemArchitecture\Labs\ISA\lab3\tb\code.txt", read_mode);

        IF init = '1' THEN
            WHILE NOT(endfile(text_file)) AND init_pointer < 2 ** address_parallelism LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                text_mem(init_pointer) <= value_instr;
                init_pointer := init_pointer + 1;
            END LOOP;
            WHILE init_pointer < 2 ** address_parallelism LOOP
                text_mem(init_pointer) <= (OTHERS => '0');
                init_pointer := init_pointer + 1;
            END LOOP;
        END IF;

        file_close(text_file);
    END PROCESS proc_init;

    instruction <= text_mem(to_integer(unsigned(gated_address)));

END ARCHITECTURE rtl;