module uniq (
    input reg clk_in,
    input reg [7:0] data_in,
    output wire [7:0] data_out_1,
    output wire [7:0] data_out_2,
    output wire [7:0] data_out_3,
    output wire [7:0] data_out_4,

    output wire data_out_valid_1,
    output wire data_out_valid_2,
    output wire data_out_valid_3,
    output wire data_out_valid_4
);


reg [7:0] values[3:0];
reg [3:0] valid_count;
reg is_unique;
reg [3:0] not_unique;
reg [3:0] i;

assign data_out_1 = (valid_count > 1) ? values[0] : 8'h00;
assign data_out_2 = (valid_count > 2) ? values[1] : 8'h00;
assign data_out_3 = (valid_count > 3) ? values[2] : 8'h00;
assign data_out_4 = (valid_count > 4) ? values[3] : 8'h00;


assign data_out_valid_1 = (valid_count > 1);
assign data_out_valid_2 = (valid_count > 2);
assign data_out_valid_3 = (valid_count > 3);
assign data_out_valid_4 = (valid_count > 4);

initial begin
  valid_count = 0;
end

always @(posedge clk_in) begin
    is_unique = 1;
    for (i = 0; i < 4; i = i + 1) begin
        if (values[i] == data_in) begin
            is_unique = 0;
            not_unique = i;
        end
    end
    
    if (is_unique) begin
        if (valid_count < 5) begin
            valid_count <= valid_count + 1;
        end
        
        for (i = 3; i > 0; i = i - 1) begin
            values[i] <= values[i-1];
        end
        values[0] <= data_in;
    end
    
    if(!is_unique) begin
      
      for (i = 3; i > 0; i = i - 1) begin
          if(i <= not_unique) begin
            values[i] <= values[i-1];
          end
          
      end
      
      values[0] <= data_in;
    end
end

endmodule



