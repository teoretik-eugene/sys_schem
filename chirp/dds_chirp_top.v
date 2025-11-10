module dds_chirp_top #(
    parameter DAC_BITS   = 12,
    parameter PHASE_BITS = 32,
    parameter FRAC_BITS  = 32
)(
    input  wire clk,
    input  wire rst,
    output wire [DAC_BITS-1:0] dac_data
);
    // параметры
    parameter N = 32;
    parameter M = 10; // LUT bits
    parameter FRAC = 32;
    // precomputed constants (подставь значения, вычисленные в скрипте)
    localparam W = N + FRAC;
    localparam [W-1:0] FTW0_ACC = 64'h000008637BD05AF7;
    localparam [W-1:0] DELTA_ACC = 64'h00000000001ABD79;

    // wires
    wire [N-1:0] ftw;
    wire [N-1:0] phase;
    wire [M-1:0] addr;
    wire [DAC_BITS-1:0] sample;

    // freq acc
    freq_acc #(N,FRAC) freq_inst (
        .clk(clk), .rst(rst),
        .delta_freq_acc(DELTA_ACC),
        .ftw0_acc(FTW0_ACC),
        .ftw_out(ftw)
    );

    // phase acc
    phase_accumulator #(N) phase_inst (
        .clk(clk), .rst(rst), .ftw(ftw), .phase(phase)
    );

    // address = phase[ N-1 : N-M ]
    assign addr = phase[N-1 -: M]; // Verilog slice: top M bits

    // ROM
    sine_rom #(M,DAC_BITS) rom_inst (
        .clk(clk), .addr(addr), .data(sample)
    );

    // output to DAC (maybe register / pipeline)
    assign dac_data = sample;

endmodule

