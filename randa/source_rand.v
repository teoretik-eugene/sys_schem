module source_rand 
#(parameter LEN =8)
(
    input clk,
    input rst,
    input ready,

    output reg valid,
    //output valid,
    output last,
    output reg [LEN-1:0] data
);

    reg [2:0] delay;
    reg [2:0] cnt;
    reg data_sent;

    assign last = valid;
    
    always @(posedge clk) begin

        if (rst) begin
            valid <= 0;
            cnt <= 0;
            delay <= 0;
            cnt <= 0;
            data_sent <= 0;
        end else begin
            /* Есть небольшой баг, который происходит когда подали сигнал ready с sum, 
                а на другом канале задержка.
            */
            if (valid && ready) begin   
                valid <= 0;
                data_sent <= 1;
                delay <= $random & 4'b1111;
                cnt <= 0;
            end else if (data_sent) begin
                if (cnt == delay) begin
                    data <= $random & 8'hFF;
                    valid <= 1;
                    data_sent <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end else if (!valid) begin
                data <= $random & 8'hFF;
                valid <= 1;
            end
        end
    end

endmodule