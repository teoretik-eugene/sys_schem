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
    output reg valid,
    output last,
    output ready_out,
    output reg [LEN-1:0] data
);

    // assign data = data_0 + data_1;
    // assign valid = valid_0 && valid_1 && ready;
    assign ready_out = ready;
    assign last = valid;
    //assign last = last_0 & last_1;

    always @(posedge clk) begin
        if (rst) begin
            valid <= 0;
            data <= 0;
        end else begin
            if (valid_0 && valid_1 && ready) begin
                data <= data_0 + data_1;
                valid <= 1;
            end else if (ready) begin
                valid <= 0;
            end
        end
    end

endmodule