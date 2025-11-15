// dds_lfm.v  — минимальная DDS LFM на fixed-point
module dds_lfm #(
    parameter N_PHASE = 32,
    parameter LUT_BITS = 10,           // log2(LUT_SIZE)
    parameter LUT_SIZE = (1<<LUT_BITS),
    parameter OUT_WIDTH = 16,          // бит выхода (signed)
    parameter [N_PHASE-1:0] INIT_FTW = 0, // FTW0 (заполнить из MATLAB)
    parameter [N_PHASE-1:0] DELTA_FTW = 0 // delta_FTW (заполнить из MATLAB)
)(
    input wire clk,
    input wire rst_n,
    output reg [15:0] dout
);

    // Фазовый аккумулятор и FTW-аккумулятор (всё целочисленное)
    reg [N_PHASE-1:0] phase_acc;
    reg [N_PHASE-1:0] ftw_acc;

    // ROM для синуса (LUT)
    // Мы предполагаем 16-bit signed данные в HEX
    reg [OUT_WIDTH-1:0] sine_rom [0:LUT_SIZE-1];

    initial begin
        $readmemh("sine_lut_unsigned16.hex", sine_rom);
        $display("DDS: LUT_SIZE=%0d, OUT_WIDTH=%0d, N_PHASE=%0d", LUT_SIZE, OUT_WIDTH, N_PHASE);
        $display("DDS: example lut[0] = %0d (0x%0h)", sine_rom[0], sine_rom[0]);
        $display("DDS: example lut[512] = %0d (0x%0h)", sine_rom[512], sine_rom[512]);
        $display("DDS: example lut[1023] = %0d (0x%0h)", sine_rom[1023], sine_rom[1023]);
        $display("DDS: INIT_FTW=%0d, DELTA_FTW=%0d", INIT_FTW, DELTA_FTW);
    end

    // Индекс в LUT — старшие биты фазы
    //wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS];
    wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= {N_PHASE{1'b0}};
            ftw_acc <= INIT_FTW[N_PHASE-1:0];
            dout <= {OUT_WIDTH{1'b0}};
        end else begin
            // Обновляем FTW-аккумулятор (линейное изменение FTW)
            ftw_acc <= ftw_acc + INIT_FTW;
            //ftw_acc   <= ftw_acc + DELTA_FTW; // FTW grows linearly
            phase_acc <= phase_acc + ftw_acc;
            dout <= sine_rom[addr];
        end
    end

endmodule
