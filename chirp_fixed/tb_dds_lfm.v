`timescale 1ns/1ps
module tb_dds_lfm;
    reg clk = 0;
    reg rst_n = 0;
    wire signed [15:0] dout;

    // Параметры должны совпадать с тем, что вы вычислили в MATLAB
    // Примерные значения (поменяйте на ваши из dds_params.txt):
    localparam N_PHASE = 32;
    localparam LUT_BITS = 10;
    localparam OUT_WIDTH = 16;
    localparam INIT_FTW = 32'h0000a7c6;   // поставить значение FTW0 (из matlab)
    localparam DELTA_FTW = 32'h00000001;  // поставить delta_FTW

    dds_lfm #(
        .N_PHASE(N_PHASE),
        .LUT_BITS(LUT_BITS),
        .OUT_WIDTH(OUT_WIDTH),
        .INIT_FTW(INIT_FTW),
        .DELTA_FTW(DELTA_FTW)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .dout(dout)
    );

    // clock
    always #0.5 clk = ~clk; // 1 MHz clock -> period 1000 ns; тут scale зависит от timescale
    initial begin
        $dumpfile("tb_dds_lfm.vcd");
        $dumpvars(0,tb_dds_lfm);
        #5;
        rst_n = 1;
        // Симулируем несколько тысяч тактов
        #50000;
        $finish;
    end
endmodule
