module dds_lfm #(
    parameter N_PHASE = 32,
    parameter integer FRAC_BITS = 12,
    parameter integer FTW_EXT = N_PHASE + FRAC_BITS,
    parameter LUT_BITS = 16,
    parameter LUT_SIZE = (1<<LUT_BITS),
    parameter OUT_WIDTH = 16,
    parameter integer LUT_WIDTH = 16

    // parameter integer F_CLK = 1_000_000,
    // parameter integer F_START = 10,
    // parameter integer F_STOP = 100,
    // parameter integer CHIRP_SAMPLES = 1_000_000
)(
    input wire clk,
    input wire rst_n,

    input wire start,
    input wire [31:0] f_start,
    input wire [31:0] f_stop,
    input wire [31:0] f_clk,
    input wire [63:0] chirp_len,

    output reg [15:0] dout,
    output reg busy,
    output reg [63:0] current_freq,
    output reg done
);
    // ROM для синуса (LUT)
    // предполагаем 16-bit signed данные в HEX
    reg [OUT_WIDTH-1:0] lut [0:LUT_SIZE-1];

    reg [FTW_EXT:0] FTW0_EXT;
    reg [FTW_EXT:0] DELTA_FTW_EXT;
    reg [N_PHASE-1:0] phase_acc = 0;
    reg [FTW_EXT-1:0] ftw_acc_ext;
    reg [63:0] sample_cnt;
    reg [1:0] state;
    reg [1:0] next_state;
    reg[31:0] f_len;
    reg [63:0] temp_freq_calc;

    initial begin
        $readmemh("sine_lut_unsigned16.hex", lut);
        $display("1<<N_PHASE = %d (0x%08x)", 1<<(N_PHASE), 1<<N_PHASE);
        $display("DDS: LUT_SIZE=%0d, OUT_WIDTH=%0d, N_PHASE=%0d", LUT_SIZE, OUT_WIDTH, N_PHASE);
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
            dout <= 0;
            busy <= 0;
            done <= 0;
            sample_cnt <= 0;
            phase_acc <= 0;
            ftw_acc_ext <= FTW0_EXT;
            state <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                2'd0: begin
                    busy <= 1'b0;
                    if (start) begin
                        //f_len = 
                        FTW0_EXT <= (f_start * (64'd1 << FTW_EXT)) / f_clk;
                        //DELTA_FTW_EXT <= ((F_STOP - F_START) * (64'd1 << FTW_EXT)) / (F_CLK * CHIRP_SAMPLES);
                        if (chirp_len != 0)
                            DELTA_FTW_EXT <= ((64'd1 << FTW_EXT)*(f_stop - f_start))/(f_clk*chirp_len);
                        else
                            DELTA_FTW_EXT <= {FTW_EXT{1'b0}};
                        $display("f_clk = %d (0x%08x)", f_clk, f_clk);
                        ftw_acc_ext <= {FTW_EXT{1'b0}};
                        phase_acc <= {N_PHASE{1'b0}};
                        sample_cnt <= 64'd0;
                        state <= 2'd1;
                        busy <= 1'b1;
                    end
                end
                2'd1: begin
                    busy <= 1'b1;

                    if (sample_cnt == 0) begin
                        ftw_acc_ext <= FTW0_EXT;
                        $display("FTW0 = %d (0x%08x)", FTW0_EXT, FTW0_EXT);
                        $display("DELTA_FTW_EXT = %d (0x%08x)", DELTA_FTW_EXT, DELTA_FTW_EXT);
                        $display("ftw_acc_ext[FTW_EXT-1 -: N_PHASE] = %d (0x%08x)", ftw_acc_ext[FTW_EXT-1 -: N_PHASE], ftw_acc_ext[FTW_EXT-1 -: N_PHASE]);
                    end else
                        ftw_acc_ext <= ftw_acc_ext + DELTA_FTW_EXT;
                    phase_acc <= phase_acc + ftw_acc_ext[FTW_EXT-1 -: N_PHASE];
                    temp_freq_calc = (ftw_acc_ext * f_clk) >> FTW_EXT;
                    current_freq <= temp_freq_calc[31:0];
                    //$display("ftw_acc_ext[FTW_EXT-1 -: N_PHASE] = %d (0x%08x)", ftw_acc_ext[FTW_EXT-1 -: N_PHASE], ftw_acc_ext[FTW_EXT-1 -: N_PHASE]);
                    //current_freq <= (ftw_acc_ext[FTW_EXT-1 -: N_PHASE] * f_clk) >> N_PHASE;
                    dout <= lut[addr];

                    sample_cnt <= sample_cnt + 1;

                    if (sample_cnt + 1 >= chirp_len) begin
                        state <= 2'd2;
                    end
                end
                2'd2: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    dout <= {OUT_WIDTH{1'b0}};
                    sample_cnt <= 32'd0;
                    phase_acc <= {N_PHASE{1'b0}};
                    ftw_acc_ext <= {FTW_EXT{1'b0}};
                    state <= 2'd0;
                end
                default: begin
                    state <= 2'd0;
                end
            endcase
        end
    end

endmodule
