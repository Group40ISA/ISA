library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU is
    port(
        opcode          : in  std_logic_vector(6 downto 0);
        Branch          : out std_logic;
        MemRead         : out std_logic;
        MemToReg        : out std_logic;
        AluOp           : out std_logic_vector(1 downto 0);
        MemWrite        : out std_logic;
        AluSrc          : out std_logic;
        Lui_ctrl		: out std_logic;
        RegWrite        : out std_logic;
        write_back_ctrl : out std_logic
    );
end entity CU;

architecture RTL of CU is

begin
    with opcode select AluOp <=
        "10" when "0110011",            --R-type: ADD, XOR, SLT
        "00" when "0010011" | "0000011", --I-type: ADDI, SRAI, ANDI, LW
        "01" when "1100011",            --B-type: BEQ
        "00" when "0010111" | "0110111", --U-type: AUIPC, LUI
        "11" when "1101111",            --UJ-type: JAL
        "00" when "0100011",            --S-type: SW
        "UU" when others;

    with opcode select Branch <=
        '1' when "1100011" | "1101111",
        '0' when others;

    with opcode select MemRead <=
        '1' when "0000011",
        '0' when "0110011" | "0010011"|"1100011"|"0100011"|"0010111"|"0110111"|"1101111",
        'U' when others;


    with opcode select MemToReg <=
        '1' when "0000011" | "0100011"|"0010111"|"1101111", 
        '0' when "0110011" | "0010011"|"1100011"|"0110111",
        'U' when others;

    with opcode select MemWrite <=
        '1' when "0100011" ,
        '0' when "0110011" | "0010011"|"1100011"|"0000011"|"0010111"|"0110111"|"1101111",
        'U' when others;

    with opcode select AluSrc <=
        '0' when "0110011" | "1100011" | "0010111" | "1101111",
        '1' when "0010011" | "0100011" | "0000011" | "0110111",
        'U' when others;

    with opcode select RegWrite <=
        '0' when "1100011" | "0100011",
        '1' when "0110011" | "0010011"|"0000011"|"0010111"|"0110111"|"1101111",
        'U' when others;

    with opcode select write_back_ctrl <=
        '1' when "0010111" | "0110111" | "1101111",
        '0' when others;
        
    with opcode select Lui_ctrl  <= 
    	'1' when "0110111",
    	'0' when others; 

end architecture RTL;
