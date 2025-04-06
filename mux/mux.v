module mux (
    input clk,
    input rst_n,

    input valid_0,
    input last_0,
    input [7:0] data_0 ,

    input valid_1,
    input last_1,
    input [7:0] data_1,
    input ready_out,        // готов передавать данные на выход
    input ready_in,

    output reg valid_out,
    output reg last_out,
    output reg [7:0] data_out,

    output ready_0,
    output ready_1
    // output reg ready_in_0,      // готов принимать данные на конкретный вход
    // output reg ready_in_1
);

    reg select = 0;

    assign ready_0 = ready_in && ~select;
    assign ready_1 = ready_in && select;

    always @(posedge clk) begin
        if (!rst_n) begin
            valid_out  <= 0;
            last_out <= 0;
            data_out <= 0;
            select <= 0;
        end
        else begin

            if (ready_in) begin
                
                if (!select) begin

                    valid_out <= valid_0;
                    last_out <= last_0;
                    data_out <= data_0;

                end else begin
                    
                    valid_out <= valid_1;
                    last_out <= last_1;
                    data_out <= data_1;
                    
                end

                if ((~select && last_0) || (select && last_1)) begin
                    select <= ~select;  // Переключение между 0 и 1
                end 
            end else begin
                valid_out <= 0;
            end

        end
    end


endmodule;

// assign ready_0 = ready_in & ~select
// assign ready_1 = ready_in & select