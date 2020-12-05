//`timescale 1ns

module tb_fp ();

	wire CLK_i;
	wire RST_n_i;
	wire [31:0] DIN_i;
	wire VIN_i;
	wire [31:0] DOUT_i;
	wire VOUT_i;
	wire END_SIM_i;

	clk_gen CG(
		.END_SIM(END_SIM_i),
		.CLK(CLK_i),
		.RST_n(RST_n_i));

	data_maker SM(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.DATA(DIN_i),
		.VOUT(VIN_i),
		.END_SIM(END_SIM_i));

	FPmul UUT(
		.FP_A(DIN_i),
		.FP_B(DIN_i),
		.clk(CLK_i),
		.FP_Z(DOUT_i));

	data_sink DS(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));
		
	shift fsm(
		.clk(CLK_i),
		.rst(RST_n_i),
		.D(VIN_i),
		.Q(VOUT_i));

endmodule

		   
