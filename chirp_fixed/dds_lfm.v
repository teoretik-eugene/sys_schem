module dds_unsigned #(
    parameter N_PHASE = 32,
    parameter LUT_BITS = 10,
    parameter LUT_SIZE = 1<<LUT_BITS,
    parameter LUT_WIDTH = 10,
    parameter INIT_FTW = 0,
    parameter DELTA_FTW = 0
)(
    input wire clk,
    input wire rst_n,
    output reg [LUT_WIDTH-1:0] dout
);

    reg [N_PHASE-1:0] phase_acc;
    reg [N_PHASE-1:0] ftw_acc;

    // unsigned ROM
    reg [LUT_WIDTH-1:0] sine_rom [0:LUT_SIZE-1];
    initial begin
        $readmemh("sine_lut_unsigned.hex", sine_rom);
    end

    wire [LUT_BITS-1:0] addr = phase_acc[N_PHASE-1 -: LUT_BITS];

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            phase_acc <= 0;
            ftw_acc <= INIT_FTW;
            dout <= 0;
        end else begin
            ftw_acc   <= ftw_acc + DELTA_FTW; // FTW grows linearly
            phase_acc <= phase_acc + ftw_acc;
            dout <= sine_rom[addr];
        end
    end
endmodule
