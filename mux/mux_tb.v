`timescale 1ns/1ns
`include "mux.v"
`include "source.v"
module mux_tb;

    reg clk = 0;
    reg rst_n;

    // Входные сигналы для источника 0
    wire valid_0;
    wire last_0;
    wire [7:0] data_0;
    wire ready_in_0;

    wire valid_out_0;
    wire valid_out_1;

   // Входные сигналы для источника 1
    wire valid_1;
    wire last_1;
    wire [7:0] data_1;
    wire ready_in_1;

    wire valid_out;
    wire last_out;
    wire [7:0] data_out;
    reg ready_out;
    wire ready_mux;

    reg start_0;
    reg start_1;

    initial 
        forever
        #5 clk = ~clk;
        

    initial
    begin

        clk = 0;
        rst_n = 0;
        ready_out = 0;
        #10
        rst_n = 1;
        ready_out = 1;
        #200
        ready_out = 1;
        // #10
        // ready_in_0 = 1;
        // ready_in_0 = 0;
        // #10
        // ready_in_1 = 1;

        // clk = 0;
        // rst_n = 0;
        // ready_out = 0;
        // #10 
        // rst_n = 1;
        // #10 
        // ready_out = 1;
        // #10
        // ready_in = 1;
        #1200
        $finish;
    end

    initial
    begin
        $dumpfile("dump.vcd");
        $dumpvars(0,mux_tb);
    end

    source
    #(.LEN(4))
     src0 (
        .clk(clk),
        .rst_n(rst_n),
        // .valid(valid[0]),
        // .last(last[0]),
        .valid(valid_0),
        .last_out(last_0),
        .data(data_0),
        .ready(ready_in_0),
        .valid_out(valid_out_0)
    );

    source 
    #(.LEN(6))
    src1 (
        .clk(clk),
        .rst_n(rst_n),
        // .valid(valid[0]),
        // .last(last[0]),
        .valid(valid_1),
        .last_out(last_1),
        .data(data_1),
        .ready(ready_in_1),
        .valid_out(valid_out_1)
    );

    mux mux (
        .clk(clk),
        .rst_n(rst_n),
        .valid_0(valid_out_0),
        .last_0(last_0),
        .data_0(data_0),
        .valid_1(valid_out_1),
        .last_1(last_1),
        .ready_in(ready_mux),
        .data_1(data_1),

        .valid_out(valid_out),
        .last_out(last_out),
        .data_out(data_out),
        .ready_out(ready_out),
        .ready_0(ready_in_0),
        .ready_1(ready_in_1)
        // .ready_in_0(ready_in_0),
        // .ready_in_1(ready_in_1)
    );

    sink snk (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_out),
        .last_in(last_out),

        .data_in(data_out),
        .ready_out(ready_mux),
        //.ready_out(ready_out),
        //.valid_out(valid_out),
        //.last_out(last_out),
        //.data_out(data_out),
        .ready_in(ready_out)

    );



endmodule