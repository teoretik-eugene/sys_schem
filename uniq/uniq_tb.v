`timescale 1ns/1ns

module uniq_tb();

    reg clk = 0;
    reg [7:0] data_in = 0;

    wire [7:0] data_out_1;
    wire [7:0] data_out_2;
    wire [7:0] data_out_3;
    wire [7:0] data_out_4;

    wire data_out_valid_1;
    wire data_out_valid_2;
    wire data_out_valid_3;
    wire data_out_valid_4;

    initial
        forever
            #5 clk = ~clk;

    initial begin

        #10
        
        data_in = 8'h01; 
        #10
        data_in = 8'h02; 
        #10
        data_in = 8'h03; 
        #10
        data_in = 8'h04; 
        #10
        data_in = 8'h02; 
        #10
        data_in = 8'h05; 
        #10
        data_in = 8'h06; 
        #10
        data_in = 8'h06; 
        #10
        data_in = 8'h04; 
        #10
        data_in = 8'h08; 
        #10
        data_in = 8'h09;
        
        
    end

    uniq unique (
            .clk_in(clk),
            .data_in(data_in),
            .data_out_1(),
            .data_out_2(),
            .data_out_3(),
            .data_out_4(),
            .data_out_valid_1(),
            .data_out_valid_2(),
            .data_out_valid_3(),
            .data_out_valid_4()
    );


endmodule

