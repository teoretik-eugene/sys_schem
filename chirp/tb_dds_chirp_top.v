`timescale 1ps / 1ps
`include "dds_chirp_top.v"

module tb_dds_chirp_top;

    // === Параметры симуляции ===
    localparam CLK_PERIOD = 10;       // 100 МГц тактовая частота
    localparam SIM_CYCLES = 20000;     // сколько тактов моделировать

    // === Параметры DDS ===
    localparam DAC_BITS   = 12;
    localparam PHASE_BITS = 32;
    localparam FRAC_BITS  = 32;

    // === Сигналы ===
    reg  clk;
    reg  rst;
    wire [DAC_BITS-1:0] dac_data;

    // === Инстанс тестируемого модуля ===
    dds_chirp_top #(
        .DAC_BITS(DAC_BITS),
        .PHASE_BITS(PHASE_BITS),
        .FRAC_BITS(FRAC_BITS)
    ) uut (
        .clk(clk),
        .rst(rst),
        .dac_data(dac_data)
    );

    // === Генерация тактового сигнала ===
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // === Основная тестовая последовательность ===
    initial begin
        // Инициализация
        rst = 1;
        #(5*CLK_PERIOD);
        rst = 0;

        // Работа DDS
        #(SIM_CYCLES * CLK_PERIOD);

        // Завершение симуляции
        $display("Simulation finished after %0d cycles", SIM_CYCLES);
        $finish;
    end

    // === Мониторинг ===
    initial begin
        $dumpfile("dds_chirp_top_tb.vcd");   // Для GTKWave
        $dumpvars(0, tb_dds_chirp_top);
        $display("Time\tclk\trst\tdac_data");
        //$monitor("%0t\t%b\t%b\t%0d", $time, clk, rst, dac_data);
    end

endmodule
