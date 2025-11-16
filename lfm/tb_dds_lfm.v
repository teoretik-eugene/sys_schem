`timescale 1ns/1ps
module tb_dds_lfm;
    reg clk = 0;
    reg rst_n = 0;
    wire [15:0] dout;

    // Параметры должны совпадать с тем, что вы вычислили в MATLAB
    // Примерные значения (поменяйте на ваши из dds_params.txt):
    localparam N_PHASE = 32;
    localparam LUT_BITS = 10;
    localparam OUT_WIDTH = 16;
    localparam LUT_WIDTH = 10;
    localparam INIT_FTW = 32'h0000002A;   // поставить значение FTW0 (из matlab)
    localparam DELTA_FTW = 32'h00000000;  // поставить delta_FTW

    dds_lfm #(
        .N_PHASE(N_PHASE),
        .LUT_BITS(LUT_BITS),
        .LUT_SIZE(1<<LUT_BITS),
        .OUT_WIDTH(OUT_WIDTH),
        .LUT_WIDTH(LUT_WIDTH),
        .F_CLK(1_000_000),
        .F_START(10),
        .F_STOP(100),
        .CHIRP_SAMPLES(100_000)
        // .INIT_FTW(INIT_FTW),
        // .DELTA_FTW(DELTA_FTW)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .dout(dout)
    );

    // clock
    always #0.5 clk = ~clk;
    initial begin
        $dumpfile("tb_dds_lfm.vcd");
        $dumpvars(0,tb_dds_lfm);
        #5;
        rst_n = 1;
        // Симулируем несколько тысяч тактов
        #10000000;
        $finish;
    end
endmodule