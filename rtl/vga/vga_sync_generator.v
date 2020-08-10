
//
// Standard VGA synchro-signal generator.
// Provides both sync signals and currently displayed pixel coordinates.
// Coordinates signal are always monotonically increasing and wrap to
// zero once maximal size is reached.
//
module vga_sync_generator #(
    parameter HSIZE = 640,
    parameter HFPORCH = 16,
    parameter HSYNC = 96,
    parameter HBPORCH = 48,
    parameter HSYNC_POSITIVE = 0,
    parameter VSIZE = 480,
    parameter VFPORCH = 10,
    parameter VSYNC = 2,
    parameter VBPORCH = 33,
    parameter VSYNC_POSITIVE = 0
    )(
    // Clock that is used to advance outputs to the next pixel.
    // Frequency must correspond to module parameters that define image format.
    input wire pixel_clk,
    input wire reset_n,

    output wire hsync,
    output wire vsync,
    output wire[$clog2(HSIZE)-1:0] pixel_x,
    output wire[$clog2(VSIZE)-1:0] pixel_y,
    output wire pixel_visible
);
    localparam HTOTAL = HSIZE + HFPORCH + HSYNC + HBPORCH;
    localparam VTOTAL = VSIZE + VFPORCH + VSYNC + VBPORCH;

    parameter HBITS = $clog2(HTOTAL);
    parameter VBITS = $clog2(VTOTAL);

    reg[HBITS-1:0] column;
    reg[VBITS-1:0] row;
    wire[HBITS-1:0] column_next;
    wire[VBITS-1:0] row_next;

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            column <= 1'b0;
        end
        else begin
            column <= column_next;
        end
    end

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            row <= 1'b0;
        end
        else begin
            row <= row_next;
        end
    end

    assign column_next = column == HTOTAL - 1 ? {HBITS{1'b0}} : column + 1'b1;
    assign row_next = column == HTOTAL - 1
                      ? (row == VTOTAL - 1 ? {VBITS{1'b0}} : row + 1'b1)
                      : row;

    reg pixel_visible_reg;
    wire pixel_visible_reg_next;

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            pixel_visible_reg <= 1'b0;
        end
        else begin
            pixel_visible_reg <= pixel_visible_reg_next;
        end
    end

    assign pixel_visible_reg_next = column_next < HSIZE && row_next < VSIZE;

    assign pixel_x = pixel_visible_reg ? column : {HBITS{1'b0}};
    assign pixel_y = pixel_visible_reg ? row : {VBITS{1'b0}};
    assign pixel_visible = pixel_visible_reg;

    reg hsync_reg;
    wire hsync_reg_next;

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            hsync_reg <= 1'b0;
        end
        else begin
            hsync_reg <= hsync_reg_next;
        end
    end

    assign hsync_reg_next = column_next >= HSIZE + HFPORCH && column_next < HSIZE + HFPORCH + HSYNC;

    assign hsync = HSYNC_POSITIVE ? hsync_reg : ~hsync_reg;

    reg vsync_reg;
    wire vsync_reg_next;

    always @(posedge pixel_clk or negedge reset_n) begin
        if (~reset_n) begin
            vsync_reg <= 1'b0;
        end
        else begin
            vsync_reg <= vsync_reg_next;
        end
    end

    assign vsync_reg_next = row_next >= VSIZE + VFPORCH && row_next < VSIZE + VFPORCH + VSYNC;

    assign vsync = VSYNC_POSITIVE ? vsync_reg : ~vsync_reg;

endmodule
