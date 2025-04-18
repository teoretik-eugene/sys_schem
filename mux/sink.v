module sink (
    input clk,
    input rst_n,
    
    input valid_in,
    input last_in,
    input [7:0] data_in,
    output reg ready_out,
    
    output reg valid_out,
    output reg last_out,
    output reg [7:0] data_out,
    input ready_in
);

    reg [1:0] counter;

    always @(posedge clk) begin

        if (!rst_n) begin
            valid_out <= 0;
            last_out <= 0;
            data_out <= 0;
            counter <= 0;
        end
        else begin
            // ready_out <= ready_in;

            if (valid_in && ready_in) begin
                valid_out <= valid_in;
                last_out <= last_in;
                data_out <= data_in;
            end
            else begin
                valid_out <= 0;
                last_out <= 0;
            end
        end

    end

    always @(posedge clk) begin
        if (!rst_n) begin
            ready_out <= 0;
            counter <= 0;
        end
        else  begin

            if (counter == 0) begin
                ready_out <= 1;
            end else if (counter == 3) begin
                ready_out <= 0;
                counter <= 0;
            end
            counter <= counter + 1;
            // counter <= counter + 1;
            // if (counter == 2) begin
            //     ready_out <= ~ready_out;
            //     counter <= 0;
            // end
            
            // код ниже, чтобы генерировать каждый такт 
            //ready_out <= ~ready_out;
            
        end
    end



endmodule;