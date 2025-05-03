module sinkr 
#(parameter LEN =8)
(
    input clk,
    input rst,
    input valid_in,
    input [LEN-1:0] data_in,
    input last_in,
    /*
        проблема в том, что входной last никак не задействуется
    */
    //output reg valid,
    output reg valid_out,
    output reg ready_out,
    output last,
    output reg [LEN-1:0] data
);

    reg [2:0] delay;
    reg [2:0] cnt;
    reg [2:0] delay_cnt;

    //assign last = valid_out;
    assign last = valid_out;

    always @(posedge clk) begin
        if (rst) begin
            ready_out <= 0;
            cnt <= 0;
            delay_cnt <= 0;
        end
        else  begin
            // if (delay_cnt == delay) begin
                
            // end
            if (cnt == 0 && delay_cnt == delay) begin
                ready_out <= 1;
            end else if (cnt == 2 && delay_cnt == delay) begin
                ready_out <= 0;
                cnt <= 0;
            end
            cnt <= cnt + 1;  
        end
    end
    /*
        генерировать сигнал ready каждые два такта. если пришло какое-то число, то принимаем его, создаем 
        рандомную задержку и опять продолжаем создавать сигнал ready два такта через один или два (просто
        продолжаем генерацию ready)
    */
    always @(posedge clk) begin
        if (valid_in && ready_out && delay_cnt == delay) begin
            data <= data_in;
            delay <= $random % 8;
            valid_out <= 1;
            delay_cnt <= 0;
        end
    end

    always @(posedge clk) begin
        if (!ready_out && (delay != delay_cnt)) begin
            delay_cnt <= delay_cnt + 1;
            valid_out <= 0;
        end
    end


endmodule