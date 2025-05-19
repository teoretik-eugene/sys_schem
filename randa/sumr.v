module sumr 
#(parameter LEN =8)
(
    //выходной вэлид равен один вх вэлид и второй вх влид и реади на выходе
    input clk,
    input rst,

    input [LEN-1:0] data_0,
    input valid_0,
    // input last_0,

    input [LEN-1:0] data_1,
    input valid_1,
    // input last_1,

    input ready,

    //output reg valid,
    output valid,
    output last,
    output ready_out,
    output [LEN-1:0] data
);

    assign valid = valid_0 && valid_1 && ready;
    assign ready_out = valid_0 && valid_1 && ready;
    assign last = valid;
    assign data = data_0 + data_1;

endmodule