// dds_lfm.v  — минимальная DDS LFM на fixed-point
module dds_lfm #(
    parameter N_PHASE = 32,
    parameter integer FTW_EXT = 64,
    parameter LUT_BITS = 10,           // log2(LUT_SIZE)
    parameter LUT_SIZE = (1<<LUT_BITS),
    parameter OUT_WIDTH = 16,          // бит выхода (signed)
    parameter integer LUT_WIDTH = 10,

    parameter integer F_CLK     = 1_000_000,
    parameter integer F_START   = 10,
    parameter integer F_STOP    = 100,
    parameter integer CHIRP_SAMPLES = 1_000_000
)(
    input wire clk,
    input wire rst_n,
    output reg [15:0] dout
);
    // FIXME проблема в том, что FTW должна вычисляться каждый раз при новой частоте, хотя мб и не так - разобраться
    localparam reg [63:0] FTW0 = (F_START * (1<<N_PHASE)) / F_CLK;

    localparam reg [63:0] DELTA_FTW = ((F_STOP - F_START) * (1<<N_PHASE)) / (F_CLK * CHIRP_SAMPLES);


    // Фазовый аккумулятор и FTW-аккумулятор (всё целочисленное)
    reg [N_PHASE-1:0] phase_acc = 0;
    reg [N_PHASE-1:0] ftw_acc = FTW0;
    reg [N_PHASE-1:0] FTW = FTW0;

    // ROM для синуса (LUT)
    // Мы предполагаем 16-bit signed данные в HEX
    reg [OUT_WIDTH-1:0] lut [0:LUT_SIZE-1];

    initial begin
        $readmemh("sine_lut_unsigned16.hex", lut);
        $display("F_START = %d (0x%08x)", F_START, F_START);
        $display("1<<N_PHASE = %d (0x%08x)", 1<<(N_PHASE-1), 1<<N_PHASE);
        $display("F_CLK = %d (0x%08x)", F_CLK, F_CLK);
        $display("FTW0 = %d (0x%08x)", FTW0, FTW0);
        $display("DELTA_FTW = %d (0x%08x)", DELTA_FTW, DELTA_FTW);
        $display("DDS: LUT_SIZE=%0d, OUT_WIDTH=%0d, N_PHASE=%0d", LUT_SIZE, OUT_WIDTH, N_PHASE);
        $display("DDS: FTW0=%0d, DELTA_FTW=%0d, N_PHASE=%0d", FTW0, DELTA_FTW, N_PHASE);
        $display("DDS: example lut[0] = %0d (0x%0h)", lut[0], lut[0]);
        $display("DDS: example lut[512] = %0d (0x%0h)", lut[512], lut[512]);
        $display("DDS: example lut[1023] = %0d (0x%0h)", lut[1023], lut[1023]);
        //$display("DDS: INIT_FTW=%0d, DELTA_FTW=%0d", INIT_FTW, DELTA_FTW);
    end

    // Индекс в LUT — старшие биты фазы
    //wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS];
    wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= {N_PHASE{1'b0}};
            ftw_acc <= FTW0;
            dout <= {OUT_WIDTH{1'b0}};
        end else begin

            // Обновляем FTW-аккумулятор (линейное изменение FTW)
            ftw_acc <= ftw_acc + DELTA_FTW;
            //ftw_acc   <= ftw_acc + DELTA_FTW; // FTW grows linearly
            phase_acc <= phase_acc + ftw_acc;       // TODO: определить почему не изменяется или не накапливается фаза
            dout <= lut[addr];
        end
    end

endmodule
