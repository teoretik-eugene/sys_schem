`timescale 1ns/1ns
`include "sinkr.v"
`include "source_rand.v"
`include "sumr.v"
module rand_tb;

    reg clk = 0;
    reg rst;

    // Входные сигналы для источника 0
    wire valid_0;
    wire last_0;
    wire [7:0] data_0;
    wire ready_in_0;
    wire valid_out_0;

   // Входные сигналы для источника 1
    wire valid_1;
    wire last_1;
    wire [7:0] data_1;
    wire ready_in_1;
    wire valid_out_1;

    wire valid_out;
    wire last_out;
    wire [7:0] data_out;

    reg ready_out;
    wire valid_sum;
    wire last_sum;
    wire [7:0] data_sum;
    wire ready_sum;

    wire valid_sink;
    wire last_sink;
    wire [7:0] data_sink;
    wire ready_sink;

    source_rand
    #(.LEN(8))
    src0 (
        .clk(clk),
        .rst(rst),
        .last(last_0),
        .data(data_0),
        .ready(ready_sum),
        .valid(valid_out_0)
    );

    sumr
    #(.LEN(8))
    sum (
        .clk(clk),
        .rst(rst),
        .data_0(data_0),
        .valid_0(valid_out_0),
        .data_1(data_1),
        .valid_1(valid_out_1),
        .last(last_sum),
        .ready(ready_sink),
        .ready_out(ready_sum),
        .valid(valid_sum),
        .data(data_sum)
    );

    sinkr
    #(.LEN(8))
    sink (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_sum),
        .data_in(data_sum),
        .valid_out(valid_sink),
        .ready_out(ready_sink),
        .last(last_sink),
        .data(data_sink)
    );


    initial 
        forever
        #5 clk = ~clk;
        
    initial
    begin

        clk = 0;
        rst = 1;
        #10
        rst = 0;
        #10
        #1200
        $finish;
    end

    initial
    begin
        $dumpfile("dump.vcd");
        $dumpvars(0,rand_tb);
    end



endmodule;