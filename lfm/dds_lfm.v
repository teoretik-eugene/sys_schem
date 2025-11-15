// dds_lfm.v  — минимальная DDS LFM на fixed-point
module dds_lfm #(
    parameter N_PHASE = 32,
    parameter LUT_BITS = 10,           // log2(LUT_SIZE) (например 1024 -> 10)
    parameter LUT_SIZE = (1<<LUT_BITS),
    parameter OUT_WIDTH = 16,          // бит выхода (signed)
    parameter INIT_FTW = 32'h00000000, // FTW0 (заполнить из MATLAB)
    parameter DELTA_FTW = 32'h00000000 // delta_FTW (заполнить из MATLAB)
)(
    input  wire clk,
    input  wire rst_n,
    output reg  signed [OUT_WIDTH-1:0] dout
);

    // Фазовый аккумулятор и FTW-аккумулятор (всё целочисленное)
    reg [N_PHASE-1:0] phase_acc;
    reg [N_PHASE-1:0] ftw_acc;

    // ROM для синуса (LUT)
    // Мы предполагаем 16-bit signed данные в HEX
    reg signed [OUT_WIDTH-1:0] sine_rom [0:LUT_SIZE-1];

    initial begin
        // Загружаем предварительно созданный файл (sine_lut.hex)
        // Убедитесь, что файл в рабочей директории симулятора.
        $readmemh("sine_lut_unsigned.hex", sine_rom);
    end

    // Индекс в LUT — старшие биты фазы
    wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS]; // Verilog-2001 bit-slice

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= {N_PHASE{1'b0}};
            ftw_acc   <= INIT_FTW[N_PHASE-1:0];
            dout      <= 0;
        end else begin
            // Обновляем FTW-аккумулятор (линейное изменение FTW)
            ftw_acc <= ftw_acc + INIT_FTW[N_PHASE-1:0] + DELTA_FTW[N_PHASE-1:0];
            phase_acc <= phase_acc + ftw_acc;
            dout <= sine_rom[addr];
        end
    end

endmodule
