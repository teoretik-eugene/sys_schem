module sine_rom #(
    parameter M = 10,
    parameter DAC_BITS = 12
)(
    input  wire                clk,
    input  wire [M-1:0]        addr,
    output reg  [DAC_BITS-1:0] data
);
    localparam SIZE = (1<<M);
    reg [DAC_BITS-1:0] rom [0:SIZE-1];
    integer i;

    initial begin
        $display("=== Loading sine.hex ===");
        $readmemh("sine.hex", rom);
        $display("=== First 8 samples of sine.hex ===");
        for (i = 0; i < 8; i = i + 1)
            $display("rom[%0d] = %h", i, rom[i]);
    end

    always @(posedge clk) begin
        data <= rom[addr];
    end
endmodule
