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

    assign last = valid;
    
    always @(posedge clk) begin

        if (rst) begin
            cnt <= 0;
            delay <= 0;
        end else begin
            if (!(ready && valid) && delay == cnt) begin
                data <= $random & 8'hFF;
                delay <= $random & 4'b1111;
                valid <= 1;
                cnt <= 0;
            end
            else if (ready) begin
                valid <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (!ready && (delay != cnt)) begin
            cnt <= cnt + 1;
            valid <= 0;
        end
    end


endmodule