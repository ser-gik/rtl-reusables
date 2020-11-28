//
// Dual-port RAM with byte-wide write strobe.
//
// Note: it is isolated in a separate module to facilitate proper BRAM inference.
//
module vga_ram32 #(
    parameter ADDR_WIDTH = 10
)(
    // RO port
    input clkA,
    input [ADDR_WIDTH-1:0] addrA,
    output [31:0] rdataA,

    // RW port
    input clkB,
    input [ADDR_WIDTH-1:0] addrB,
    output [31:0] rdataB,
    input [3:0] wstrobeB,
    input [31:0] wdataB
);
    reg [31:0] RAM[0:(2**ADDR_WIDTH)-1];

    reg [31:0] rdataA,
    always @(posedge clkA) begin
        rdataA <= RAM[addrA];
    end

    reg [31:0] rdataB,
    always @(posedge clkB) begin
        if (wstrobeB[0]) RAM[addrB][7:0] <= in[7:0];
        if (wstrobeB[1]) RAM[addrB][15:8] <= in[15:8];
        if (wstrobeB[2]) RAM[addrB][23:16] <= in[23:16];
        if (wstrobeB[3]) RAM[addrB][31:24] <= in[31:24];
        rdataB <= RAM[addrB];
    end

endmodule

