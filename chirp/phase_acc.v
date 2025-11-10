module phase_accumulator #(
    parameter N = 32
)(
    input  wire               clk,
    input  wire               rst,
    input  wire [N-1:0]       ftw,      // frequency tuning word
    output reg  [N-1:0]       phase
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            phase <= {N{1'b0}};
        else
            phase <= phase + ftw; // естественное переполнение (mod 2^N)
    end
endmodule
