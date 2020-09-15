
//
// Generates signals to drive character RAM reads and glyph bitmap pixel
// selects for text VGA console.
//
// Outputs are 1-clock delayed to VGA clock signal.
//
module vga_console_sync #(
    // How many text characters to fit into one line.
    parameter TEXT_COLUMNS = 10,
    // How many text rows to fit into frame.
    parameter TEXT_ROWS = 5,
    // Pixel width of character bitmap.
    parameter GLYPH_COLUMNS = 9,
    // Pixel height of character bitmap.
    parameter GLYPH_ROWS = 14,
    // Binary logarithm of a scale factor to proportionally increase an area
    // that is occupied by a single character. This may be useful if user
    // wants to "zoom" displayed text without providing different font ROM.
    // Value of '0' means "display glyphs as is" (i.e. scale is '1').
    // For example if font ROM bitmaps are 9x14, this value will change
    // displayed glyph size in the next way:
    // 0: (9 * 2**0)x(14 * 2**0) = 9x14
    // 2: (9 * 2**2)x(14 * 2**2) = 36x56
    // so on.
    //
    parameter GLYPH_SCALE_LOG = 0,

    // Internal, do not override
    parameter _CHAR_ADDR_WIDTH = $clog2(TEXT_COLUMNS * TEXT_ROWS),
    parameter _GLYPH_COLUMN_WIDTH = $clog2(GLYPH_COLUMNS),
    parameter _GLYPH_ROW_WIDTH = $clog2(GLYPH_ROWS),
    parameter _GLYPH_COLUMN_REG_WIDTH = _GLYPH_COLUMN_WIDTH + GLYPH_SCALE_LOG,
    parameter _GLYPH_ROW_REG_WIDTH = _GLYPH_ROW_WIDTH + GLYPH_SCALE_LOG
) (
    // VGA pixel clock.
    input pixel_clk,
    // Should be asserted for the first visible pixel of each scan line.
    input line_start,
    // Should be asserted for the first visible pixel of each frame.
    input frame_start,

    input reset_n,

    // Address of a current character.
    // Character RAM is assumed to store codepoints "from left to right" and
    // lines "from top to bottom", with no extra padding between lines.
    output [_CHAR_ADDR_WIDTH - 1:0] char_address,
    // Current character pixel Y coordinate ('0' for topmost pixels).
    output [_GLYPH_ROW_WIDTH - 1:0] glyph_row,
    // Current character pixel X coordinate ('0' for leftmost pixels).
    output [_GLYPH_COLUMN_WIDTH - 1:0] glyph_column,
    // Is asserted when currently displayed pixel is outside of text area,
    // which is described by module parameters.
    output idle
);
    localparam [_GLYPH_COLUMN_WIDTH - 1:0] GLYPH_COLUMNS_MAX = GLYPH_COLUMNS - 1;
    localparam [_GLYPH_ROW_WIDTH - 1:0] GLYPH_ROWS_MAX = GLYPH_ROWS - 1;
    // Outputs
    reg [_CHAR_ADDR_WIDTH - 1:0] char_address_reg;
    wire [_CHAR_ADDR_WIDTH - 1:0] char_address_reg_next;
    reg [_GLYPH_ROW_REG_WIDTH - 1:0] glyph_row_reg;
    wire [_GLYPH_ROW_REG_WIDTH - 1:0] glyph_row_reg_next;
    reg [_GLYPH_COLUMN_REG_WIDTH - 1:0] glyph_column_reg;
    wire [_GLYPH_COLUMN_REG_WIDTH - 1:0] glyph_column_reg_next;
    reg idle_reg;
    wire idle_reg_next;

    assign char_address = char_address_reg;
    assign glyph_row = glyph_row_reg[_GLYPH_ROW_REG_WIDTH - 1:GLYPH_SCALE_LOG];
    assign glyph_column = glyph_column_reg[_GLYPH_COLUMN_REG_WIDTH - 1:GLYPH_SCALE_LOG];
    assign idle = idle_reg;

    // Text column of a current character.
    reg [_CHAR_ADDR_WIDTH - 1:0] char_column_reg;
    wire [_CHAR_ADDR_WIDTH - 1:0] char_column_reg_next;

    wire glyph_column_wrap;
    assign glyph_column_wrap = line_start || glyph_column_reg ==
            {GLYPH_COLUMNS_MAX, {GLYPH_SCALE_LOG{1'b1}}};

    wire char_column_wrap;
    assign char_column_wrap =
        line_start || (char_column_reg == TEXT_COLUMNS - 1 && glyph_column_wrap);

    wire glyph_row_wrap;
    assign glyph_row_wrap =
        frame_start || (glyph_row_reg == {GLYPH_ROWS_MAX, {GLYPH_SCALE_LOG{1'b1}}} && char_column_wrap);

    wire char_address_wrap;
    assign char_address_wrap =
        frame_start || (char_address == TEXT_COLUMNS * TEXT_ROWS - 1 && glyph_row_wrap);

    assign idle_reg_next = frame_start || (line_start && ~char_address_wrap) ?
                            1'b0 : char_column_wrap || char_address_wrap;

    assign glyph_column_reg_next = glyph_column_wrap ? {_GLYPH_COLUMN_REG_WIDTH{1'b0}}
                                    : glyph_column_reg + 1'b1;

    assign char_column_reg_next = char_column_wrap ? {_CHAR_ADDR_WIDTH{1'b0}}
                                    : (glyph_column_wrap ? char_column_reg + 1'b1 : char_column_reg);

    assign glyph_row_reg_next = glyph_row_wrap ? {_GLYPH_ROW_REG_WIDTH{1'b0}}
                                    : (char_column_wrap ? glyph_row_reg + 1'b1 : glyph_row_reg);

    assign char_address_reg_next =
        char_address_wrap ? {_CHAR_ADDR_WIDTH{1'b0}}
            : (glyph_row_wrap ? char_address_reg + 1'b1
                : (char_column_wrap ? char_address_reg - char_column_reg
                    : (glyph_column_wrap ? char_address_reg + 1'b1 : char_address_reg)));

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            idle_reg <= 1'b0;
        end
        else begin
            idle_reg <= idle_reg_next;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            char_address_reg <= {_CHAR_ADDR_WIDTH{1'b0}};
        end
        else if (~idle_reg_next) begin
            char_address_reg <= char_address_reg_next;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            glyph_row_reg <= {_GLYPH_ROW_REG_WIDTH{1'b0}};
        end
        else if (~idle_reg_next) begin
            glyph_row_reg <= glyph_row_reg_next;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            glyph_column_reg <= {_GLYPH_COLUMN_REG_WIDTH{1'b0}};
        end
        else if (~idle_reg_next) begin
            glyph_column_reg <= glyph_column_reg_next;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            char_column_reg <= {_CHAR_ADDR_WIDTH{1'b0}};
        end
        else if (~idle_reg_next) begin
            char_column_reg <= char_column_reg_next;
        end
    end

endmodule

