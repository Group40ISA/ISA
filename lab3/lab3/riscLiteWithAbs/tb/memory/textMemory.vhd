--------------------------------------------------------------------------------
--  text_emory which takes initialisation content form a file.                --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY textMemory IS
    GENERIC(
        address_parallelism     : INTEGER := 32;
        instruction_parallelism : INTEGER := 32);
    PORT(clk, rst                             : in  std_logic;
         address                              : IN  STD_LOGIC_VECTOR(address_parallelism - 1 DOWNTO 0);
         init                                 : IN  STD_LOGIC;
         pipe_stall, pipe_flush1, pipe_flush2 : IN  std_logic;
         end_code                             : OUT STD_LOGIC;
         instruction                          : OUT STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0)
        );
END ENTITY textMemory;

ARCHITECTURE rtl OF textMemory IS

    FILE text_file : text;

    SIGNAL last_add          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal endcode_shift_reg : std_logic_vector(3 downto 0);
    signal end_code_sig      : std_logic;
    TYPE memory IS ARRAY (4194424 DOWNTO 4194304) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL text_mem          : memory;

BEGIN

    proc_init : PROCESS(init, address)  --@suppressive
        VARIABLE in_instr_line : line;
        VARIABLE init_pointer  : INTEGER := 4194304; -- variable that points at successive lines of the memory for every read line
        VARIABLE value_instr   : STD_LOGIC_VECTOR(instruction_parallelism - 1 DOWNTO 0);
    BEGIN
        IF init = '1' THEN
            file_open(text_file, "/home/isa40/Desktop/lab3/riscLiteWithoutABS/tb/memory/code.txt", read_mode);
            WHILE NOT (endfile(text_file)) and init_pointer <= 4194388 LOOP -- stops the loop if exceed text_memory dim.
                readline(text_file, in_instr_line);
                read(in_instr_line, value_instr);
                text_mem(init_pointer)     <= value_instr(31 DOWNTO 24);
                text_mem(init_pointer + 1) <= value_instr(23 DOWNTO 16);
                text_mem(init_pointer + 2) <= value_instr(15 DOWNTO 8);
                text_mem(init_pointer + 3) <= value_instr(7 DOWNTO 0);
                init_pointer               := init_pointer + 4;
            END LOOP;
            file_close(text_file);
            last_add <= STD_LOGIC_VECTOR(to_unsigned(init_pointer - 4, 32)); --CHANGE init_pointer-8 -> init_pointer
        ELSIF init = '0' and to_integer(unsigned(address)) >= 4194304 THEN
            instruction(31 DOWNTO 24) <= text_mem(to_integer(unsigned(address)));
            instruction(23 DOWNTO 16) <= text_mem(to_integer(unsigned(address) + 1));
            instruction(15 DOWNTO 8)  <= text_mem(to_integer(unsigned(address) + 2));
            instruction(7 DOWNTO 0)   <= text_mem(to_integer(unsigned(address) + 3));
        END IF;

        IF init = '1' then              --CHANGE added the control on init to initialise end_code
            end_code_sig <= '0';        -- stack-at-1 otherwise.
        elsif (address = last_add) THEN
            end_code_sig <= '1';
            -- ELSE                 --CHANGE removed ELSE to avoid toggling of end_code
            --    end_code <= '0';  -- that nullify its purpose
        END IF;
    END PROCESS proc_init;

    shift_end_code : process(clk, rst) -- implements the shift register for the end_code signal
    begin                              -- so to emulate the pipe stages with the proper control
        if rst = '1' then              -- signal from the hazard detection unit which acts on the pipe
            endcode_shift_reg <= (others => '0');
        elsif clk'event and clk = '1' then
            if pipe_flush2 = '1' then
                endcode_shift_reg(1) <= '0';
            elsif pipe_stall = '1' then
                endcode_shift_reg(1) <= endcode_shift_reg(1);
            else
                endcode_shift_reg(0)          <= end_code_sig;
                endcode_shift_reg(3 downto 1) <= endcode_shift_reg(2 downto 0);
            end if;

            if pipe_flush1 = '1' then
                endcode_shift_reg(1) <= '0';
            else
                endcode_shift_reg(0)          <= end_code_sig;
                endcode_shift_reg(3 downto 1) <= endcode_shift_reg(2 downto 0);
            end if;
        end if;
    end process;
    end_code <= endcode_shift_reg(3);
END ARCHITECTURE rtl;
