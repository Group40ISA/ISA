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
        instruction_parallelism : INTEGER := 32);
    PORT(
        address     : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
        init        : IN  STD_LOGIC;
        end_code    : OUT STD_LOGIC;
        instruction : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
    );
END ENTITY text_memory;

ARCHITECTURE rtl OF text_memory IS

    FILE text_file : text;

    SIGNAL last_add : STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE memory IS ARRAY (4194424 DOWNTO 4194304) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL text_mem : memory;

BEGIN


    proc_init : PROCESS(init, address) --@suppressive
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer  : INTEGER := 4194304; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr   : STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
    BEGIN
        IF init = '1' THEN
            file_open(text_file, "/home/raffaele/Scrivania/Uni/II anno/ISA/git_hub/ISA/ISA/lab3/tb/memory/code_test.txt", read_mode);
            WHILE NOT (endfile(text_file)) and init_pointer <=4194388 LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                text_mem(init_pointer)     <= value_instr(31 DOWNTO 24);
                text_mem(init_pointer + 1) <= value_instr(23 DOWNTO 16);
                text_mem(init_pointer + 2) <= value_instr(15 DOWNTO 8);
                text_mem(init_pointer + 3) <= value_instr(7 DOWNTO 0);
                init_pointer               := init_pointer + 4;
            END LOOP;
            file_close(text_file);
            last_add <= STD_LOGIC_VECTOR(to_unsigned(init_pointer-8, 32));
        ELSIF init = '0' THEN
            instruction(31 DOWNTO 24) <= text_mem(to_integer(unsigned(address)));
            instruction(23 DOWNTO 16) <= text_mem(to_integer(unsigned(address) + 1));
            instruction(15 DOWNTO 8)  <= text_mem(to_integer(unsigned(address) + 2));
            instruction(7 DOWNTO 0)   <= text_mem(to_integer(unsigned(address) + 3));
        END IF;
        IF (address = last_add) THEN
            end_code <= '1';
        ELSE
            end_code <= '0';
        END IF;
    END PROCESS proc_init;
    
END ARCHITECTURE rtl;
