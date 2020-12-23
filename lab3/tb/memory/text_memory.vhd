--------------------------------------------------------------------------------
--  text_emory which takes initialisation content form a file.                --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY text_memory IS
    GENERIC(
        address_parallelism     : INTEGER := 32;
        instruction_parallelism : INTEGER := 32;
        memory_depth            : integer := 5);
    PORT(
        address     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        init        : IN  STD_LOGIC;
        end_code    : out STD_LOGIC;
        instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
    );
END ENTITY text_memory;

ARCHITECTURE rtl OF text_memory IS

    FILE text_file : text;

    SIGNAL gated_address : STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
    SIGNAL init_ext      : STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
    signal last_add      : std_logic_Vector(31 downto 0);
    TYPE memory IS ARRAY (4 * (2**memory_depth) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL text_mem      : memory;

BEGIN

    init_ext      <= (OTHERS => init);
    gated_address <= address AND NOT (init_ext); -- when the memory is being initialized, it does not accept input address

    proc_init : PROCESS(init)
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer  : INTEGER := 0; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr   : STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
    BEGIN
        file_open(text_file, "/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/lab3/tb/memory/code.txt", read_mode);
        IF init = '1' THEN
            WHILE NOT (endfile(text_file)) AND init_pointer < 4 * (2 ** memory_depth) LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                text_mem(init_pointer)     <= value_instr(31 downto 24);
                text_mem(init_pointer + 1) <= value_instr(23 downto 16);
                text_mem(init_pointer + 2) <= value_instr(15 downto 8);
                text_mem(init_pointer + 3) <= value_instr(7 downto 0);
                init_pointer               := init_pointer + 4;
            END LOOP;
            last_add <= std_logic_vector(to_unsigned(init_pointer,32));
            WHILE init_pointer < 4 * (2 ** memory_depth) LOOP
                text_mem(init_pointer)     <= (OTHERS => '0');
                text_mem(init_pointer + 1) <= (OTHERS => '0');
                text_mem(init_pointer + 2) <= (OTHERS => '0');
                text_mem(init_pointer + 3) <= (OTHERS => '0');
                init_pointer               := init_pointer + 4;
            END LOOP;
        END IF;
        file_close(text_file);
    END PROCESS proc_init;
   
    instruction(31 downto 24) <= text_mem(to_integer(unsigned(gated_address)));
    instruction(23 downto 16) <= text_mem(to_integer(unsigned(gated_address) + 1));
    instruction(15 downto 8)  <= text_mem(to_integer(unsigned(gated_address) + 2));
    instruction(7 downto 0)   <= text_mem(to_integer(unsigned(gated_address) + 3));
    
    process(gated_address)
    begin
        if (gated_address = last_add) then
            end_code <= '1';
        else
            end_code <= '0';
        end if;
    end process;
    
END ARCHITECTURE rtl;
