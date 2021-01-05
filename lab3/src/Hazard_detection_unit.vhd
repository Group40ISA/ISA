library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----to have lower number of NOP, it 's possible to move the and related to target address in the stage of execution
-----in this way we 'll have only 2 NOP rather than 3

entity Hazard_detection_unit is
	port(
		rs1, rs2, rd_ID_EX, rd_EX_MEM : in  std_logic_vector(4 downto 0);
		mem_wrt                       : in  std_logic;
		effective_branch              : in  std_logic;
		clk                           : in  std_logic;
		rst                           : in  std_logic;
		opcode                        : in  std_logic_vector(6 downto 0);
		sel_ctrl                      : out std_logic;
		pc_enable                     : out std_logic; ---but it is not useful: the pc has never stopped
		nop_injector                  : out std_logic
	);
end entity Hazard_detection_unit;

architecture RTL of Hazard_detection_unit is

begin
	beq : process(effective_branch, rst)
	begin
		if (rst = '1') then
			sel_ctrl     <= '0';
			pc_enable    <= '0';
			nop_injector <= '0';
		else
			if (effective_branch = '1') then
				sel_ctrl     <= '1';
				nop_injector <= '1';
			else
				sel_ctrl     <= '0';
				nop_injector <= '0';
			end if;
		end if;

	end process;

end architecture RTL;
