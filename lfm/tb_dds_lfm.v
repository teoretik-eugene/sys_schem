`timescale 1ns/1ns
module tb_dds_lfm;
    reg clk = 0;
    reg rst_n = 0;
    wire [15:0] dout;
    wire done;
    wire [63:0] current_freq;
    reg [31:0] f_start;
    reg [31:0] f_end;
    reg [63:0] chirp_len;
    reg [31:0] f_clk;
    wire busy;
    reg start;
    
    localparam N_PHASE = 32;
    localparam LUT_BITS = 16;
    localparam OUT_WIDTH = 16;
    localparam LUT_WIDTH = 16;

    integer f;

    dds_lfm #(
        .N_PHASE(N_PHASE),
        .LUT_BITS(LUT_BITS),
        .LUT_SIZE(1<<LUT_BITS),
        .OUT_WIDTH(OUT_WIDTH),
        .LUT_WIDTH(LUT_WIDTH)
        //.F_CLK(1_000_000),
        //.F_START(10),
        //.F_STOP(100),
        //.CHIRP_SAMPLES(1_000_000)
        // .INIT_FTW(INIT_FTW),
        // .DELTA_FTW(DELTA_FTW)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .f_start(f_start),
        .f_stop(f_end),
        .chirp_len(chirp_len),
        .busy(busy),
        .start(start),
        .f_clk(f_clk),
        .done(done),
        .current_freq(current_freq),
        .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_dds_lfm.vcd");
        $dumpvars(0,tb_dds_lfm);

        f = $fopen("dds_output.txt", "w");

        f_start = 10;
        f_end = 1000;
        chirp_len = 100_000_000;
        start = 1;
        f_clk = 100_000_000;
        #5;
        start = 1;
        rst_n = 1;
        #5
        start = 0;
        #1000000000;
        #50;
        // закрываем файл
        $fclose(f);
        $display("Simulation finished.");
        $finish;
    end

    always @(posedge clk) begin
        if (busy)
            $fwrite(f, "%0d\n", dout);
    end
endmodule