
//
// TODO
//
module vga_text_console #(
    // Number of characters per one line of displayed text
    parameter TEXT_COLUMNS = 80,
    // Number of displayed lines
    parameter TEXT_ROWS = 25,
    // Pixel width of a character bitmap
    parameter GLYPH_WIDTH = 16,
    // Pixel height of a character bitmap
    parameter GLYPH_HEIGHT = 8,
    // Active polarity of an incoming hsync
    parameter HSYNC_POSITIVE = 1,
    // Active polarity of an incoming vsync
    parameter VSYNC_POSITIVE = 1
    ) (
    input reset_n,

    // VGA clock line
    input vga_clk,
    // VGA horizontal sync, polarity as per HSYNC_POSITIVE
    input vga_hsync,
    // VGA vertical sync, polarity as per VSYNC_POSITIVE
    input vga_vsync,
    // Whether currently selected pixel belongs to a visible area or not
    input vga_visible,

    // Character RAM clock line
    input chram_clk,
    // Character RAM current address
    input [$clog2(TEXT_COLUMNS * TEXT_ROWS)-1:0] chram_addr,
    // Character RAM data to write. Write is synchronized by chram_clk.
    input [7:0] chram_data,

    // Font ROM driver clock
    output fontrom_clk,
    // Font ROM codepoint selection
    output [7:0] fontrom_codepoint,
    // Font ROM glyph line selection
    output [$clog2(GLYPH_HEIGHT)-1:0] fontrom_glyph_line_idx,
    // Font ROM glyph line
    input [GLYPH_WIDTH-1:0] fontrom_glyph_line,

    // Text console pixel output
    output text_pixel_out
);
    // Active high sync signals.
    wire hsync;
    wire vsync;

    assign hsync = HSYNC_POSITIVE ? vga_hsync : ~vga_hsync;
    assign vsync = VSYNC_POSITIVE ? vga_vsync : `vga_vsync;

    localparam NUM_CHARACTERS = TEXT_COLUMNS * TEXT_ROWS;
    parameter CHRAM_ADDR_WIDTH = $clog2(NUM_CHARACTERS);
    parameter TEXT_COL_WIDTH = $clog2(TEXT_COLUMNS);

    parameter GLYPH_ROW_ADDR_WIDTH = $clog2(GLYPH_HEIGHT);
    parameter GLYPH_COL_ADDR_WIDTH = $clog2(GLYPH_WIDTH);


    reg[CHRAM_ADDR_WIDTH-1:0] text_line_first_char_addr;
    reg[TEXT_COL_WIDTH-1:0] text_column;
    reg[GLYPH_ROW_ADDR_WIDTH-1:0] text_glyph_row;
    reg[GLYPH_WIDTH-1:0] text_glyph_column_mask;











    reg[7:0] chram[0:NUM_CHARACTERS-1];

    //
    // Character RAM write operations.
    //
    always @(posedge chram_clk) begin
        chram[chram_addr] <= chram_data;
    end






    //
    // Stage 1.
    // Compute character address and pixel address withing character bitmap.
    //


    reg[CHRAM_ADDR_WIDTH-1:0] char_address;
    wire[CHRAM_ADDR_WIDTH-1:0] next_char_address;

    reg[GLYPH_ROW_ADDR_WIDTH-1:0] glyph_line_index;
    wire[GLYPH_ROW_ADDR_WIDTH-1:0] next_glyph_line_index;

    reg[GLYPH_COL_ADDR_WIDTH-1:0] glyph_column_index;
    wire[GLYPH_COL_ADDR_WIDTH-1:0] next_glyph_column_index;







    //
    // Stage 2.
    // Read character.
    //
    reg[7:0] codepoint;
    reg[GLYPH_ROW_ADDR_WIDTH-1:0] glyph_line_index_2;
    reg[GLYPH_COL_ADDR_WIDTH-1:0] glyph_column_index_2;

    always @(posedge vga_clk) begin
        codepoint <= chram[char_address];
    end

    always @(posedge vga_clk) begin
        glyph_line_index_2 <= glyph_line_index;
    end

    always @(posedge vga_clk) begin
        glyph_column_index_2 <= glyph_column_index;
    end

    //
    // Stage 3.
    // Read bitmap line.
    //
    wire[GLYPH_WIDTH-1:0] glyph_line;
    reg[GLYPH_COL_ADDR_WIDTH-1:0] glyph_column_index_3;

    assign fontrom_clk = vga_clk;
    assign fontrom_codepoint = codepoint;
    assign fontrom_glyph_line_idx = glyph_line_index_2;
    assign glyph_line = fontrom_glyph_line;

    always @(posedge vga_clk) begin
        glyph_column_index_3 <= glyph_column_index2;
    end

    //
    // Stage 4.
    // Select pixel.
    //
    reg text_pixel_out;
    wire next_text_pixel_out;

    assign next_text_pixel_out = glyph_line[glyph_column_index_2];

    always @(posedge vga_clk) begin
        text_pixel_out <= next_text_pixel_out;
    end

endmodule

