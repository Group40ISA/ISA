library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		A, B : in std_logic_vector (31 downto 0);
		AluCtrl : in std_logic_vector (3 downto 0);
		zero : out std_logic; 
		result: out std_logic_vector (31 downto 0)
	);
end entity ALU;

architecture RTL of ALU is
	
	signal A_sel, B_sel : std_logic;
	signal Mux_sel : std_logic_vector (1 downto 0);
	signal Op1, Op2 : std_logic_vector (31 downto 0);
	signal Add_out, Shift_out : std_logic_vector (31 downto 0);
	signal zero1 : std_logic_vector (31 downto 0);
	signal set : std_logic_vector(31 downto 0);
	signal Adder_mux_out : std_logic_vector(31 downto 0);
	signal B_sel_extended : std_logic_vector(31 downto 0);
	signal Slt_ctrl : std_logic_vector(1 downto 0);
	signal set_zero : std_logic_vector(31 downto 0);
	  
	
begin
	A_sel <= AluCtrl(3);
	B_sel <= AluCtrl(2);

	Mux_sel <= AluCtrl(1 downto 0);
	
	zero1 <= (others => '0');
	
	set <= (0 => '1', others => '0') ;
	set_zero <= (others => '0') ;
	
	B_sel_extended <= (0 => B_sel, others  => '0');
	
	Slt_ctrl  <= Add_out(31) & B_sel;
	
	with A_sel select Op1 <=
		A when '0',
		not A when '1',
		(others => 'U') when others;
		
	with B_sel select Op2 <=
		B when '0',
		not B when '1',
		(others => 'U') when others;
		
	with Mux_sel select result <=
		(Op1 and Op2) when "00",
		Adder_mux_out when "11",
		Shift_out when "10",
		(Op1 xor Op2) when "01",
		(others => 'U') when others; 
		
	Add_out <= std_logic_vector(signed(Op1) + signed(Op2) + signed(B_sel_extended));
	process(Add_out)
	begin
		if(Add_out = zero1 )then
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process;
	
	with Slt_ctrl select  Adder_mux_out  <= 
		Add_out when "00" | "10",
		set when "11",
		set_zero when "01",
		(others => 'U') when others;
		
	Shift_out <= std_logic_vector(shift_right(signed(Op1),to_integer(unsigned(Op2(3 downto 0)))));
	
		 

end architecture RTL;
