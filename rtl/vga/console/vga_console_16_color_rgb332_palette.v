
module vga_console_16_color_rgb332_palette (
    input clk,
    input [3:0] color_idx,
    output [7:0] rgb332
);
    reg [7:0] rgb332

    always @(posedge clk) begin
        case (color_idx)
            //                 rrrgggbb
            4'h0: rgb332 <= 8'b11111111; // White
            4'h1: rgb332 <= 8'b00000000; // Black
            4'h2: rgb332 <= 8'b00000000;
            4'h3: rgb332 <= 8'b00000000;
            4'h4: rgb332 <= 8'b00000000;
            4'h5: rgb332 <= 8'b00000000;
            4'h6: rgb332 <= 8'b00000000;
            4'h7: rgb332 <= 8'b00000000;
            4'h8: rgb332 <= 8'b00000000;
            4'h9: rgb332 <= 8'b00000000;
            4'ha: rgb332 <= 8'b00000000;
            4'hb: rgb332 <= 8'b00000000;
            4'hc: rgb332 <= 8'b00000000;
            4'hd: rgb332 <= 8'b00000000;
            4'he: rgb332 <= 8'b00000000;
            4'hf: rgb332 <= 8'b00000000;
        endcase
    end

endmodule

