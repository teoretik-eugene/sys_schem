module freq_acc #(
    parameter N    = 32,     // FTW width
    parameter FRAC = 32      // дробные биты
)(
    input  wire               clk,
    input  wire               rst,
    input  wire [N+FRAC-1:0]  delta_freq_acc, // предвычисленное константное приращение
    input  wire [N+FRAC-1:0]  ftw0_acc,       // FTW0 << FRAC (загружать при запуске)
    output reg  [N-1:0]       ftw_out
);
    localparam W = N + FRAC;
    reg [W-1:0] freq_acc_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            freq_acc_reg <= ftw0_acc;
            ftw_out <= ftw0_acc[W-1:FRAC];
        end else begin
            freq_acc_reg <= freq_acc_reg + delta_freq_acc;
            ftw_out <= freq_acc_reg[W-1:FRAC]; // старшие N бит -> FTW
        end
    end
endmodule

