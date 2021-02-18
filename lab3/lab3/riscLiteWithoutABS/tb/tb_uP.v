//////////////////////////////////////////
// ISA GROUP 40 - 20/01/2021            //
// VERILOG TEST BENCH FOR THE RISC_LITE //
//////////////////////////////////////////

module tb_uP();

    wire CLK_i;
    wire RST_i;
    wire END_SIM_i;
    wire init;
    wire pipe_flush1, pipe_flush2, pipe_stall;
    wire [31:0] instruction;
    wire [31:0] data;
    wire [31:0] pc;
    wire [31:0] out_rf;
    wire [31:0] alu_result;
    wire data_mem_read, data_mem_write;

    clk_gen CG(.END_SIM(END_SIM_i),
        .clk(CLK_i),
        .rst(RST_i),
        .init(init));

    dataMemory #(.address_parallelism(32), .data_parallelism(32)) DM(.init(init),
        .input_data(out_rf),
        .address(alu_result),
        .end_code(END_SIM_i),
        .read_en(data_mem_read),
        .write_en(data_mem_write),
        .output_data(data)
    );

    textMemory #(.address_parallelism(32), .instruction_parallelism(32)) TM(.clk(CLK_i),
        .rst(RST_i),
        .pipe_stall(pipe_stall),
        .pipe_flush1(pipe_flush1),
        .pipe_flush2(pipe_flush2),
        .address(pc),
        .init(init),
        .end_code(END_SIM_i),
        .instruction(instruction));

    uP  risc_lite(.clk(CLK_i),
        .rst(RST_i),
        .instruction(instruction),
        .data(data),
        .pc(pc),
        .out_rf(out_rf),
        .alu_result(alu_result),
        .data_mem_read(data_mem_read),
        .data_mem_write(data_mem_write),
        .pipe_stall(pipe_stall),
        .pipe_flush1(pipe_flush1),
        .pipe_flush2(pipe_flush2));

endmodule
