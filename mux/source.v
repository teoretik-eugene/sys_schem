module source (
    input clk,
    input rst_n,
    output reg valid,
    output valid_out,
    output reg last,
    output reg [7:0] data,
    output last_out,
    input ready
);

    reg [7:0] counter;
    reg last_flag;
    reg [7:0] valid_counter;
    assign valid_out = valid;
    assign last_out = valid_out && ((counter + 1) % 4 == 0) && ready;

    always @(*)
        data = counter;

    always @(posedge clk) begin
        if (!rst_n) begin
            valid <= 0;
            last <= 0;
            counter <= 0;
            last_flag <= 0;
            valid_counter <= 0;
        end else begin
            valid_counter <= valid_counter + 1;

            if (~valid && valid_counter == 0) begin
                valid <= 1;
            end // else
            if (last_out)
                valid <= 0;

            if (valid_counter == 19) begin  //обнуляем
                valid_counter <= 0;
            end

            if (ready && valid_out) begin
                counter <= counter + 1;
            end
        end
    end

endmodule;