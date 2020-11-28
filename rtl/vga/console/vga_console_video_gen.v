
module vga_console_video_gen(
    input clk,
    input blink_clk,
    input [7:0] char_code,
    input [3:0] char_attrs,
    input [3:0] glyph_x,
    input [4:0] glyph_y,
    output video
);
    wire [15:0] line;
    reg [3:0] column;
    reg [4:0] row;

    always @(posedge clk) column <= glyph_x;
    always @(posedge clk) row <= glyph_y;

    fontrom_16x32__xos4_Terminus_Medium_R_Normal__32_320_72_72_C_160_ISO10646_1 u_fontrom(
        .codepoint(char_code[7] ? {7{1'b0}} : char_code[6:0]),
        .glyph_line_idx(glyph_y),
        .clk(clk),
        .glyph_line(line)
    );

    wire pixel_fontrom;
    assign pixel_fontrom = line[column];

    wire is_blinking;
    wire is_underlined;
    wire is_crossedout;
    wire is_inverted;

    assign is_blinking = char_attrs[3];
    assign is_underlined = char_attrs[2];
    assign is_crossedout = char_attrs[1];
    assign is_inverted = char_attrs[0];

    wire pixel_with_overlays;
    assign pixel_with_overlays = pixel_fontrom
                         || (is_underlined && (row == 5'd28 || row == 5'd29))
                         || (is_crossedout && (rom == 5'd15 || row == 5'd16));

    assign video = is_blinking && ~blink_clk ? 1'b0 : pixel_with_overlays ^ is_inverted;

endmodule

