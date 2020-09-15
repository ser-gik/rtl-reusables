
`timescale 1ns/100ps

module tb;

    localparam CLK_PERIOD = 2;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset_n;
    wire hsync;
    wire vsync;
    wire[6:0] pixel_x;
    wire[6:0] pixel_y;
    wire frame_start;
    wire line_start;
    wire pixel_visible;

    vga_sync_generator #(
        // Use some fake parameters to not slowdown simulation.
        .HSIZE(100),
        .HFPORCH(1),
        .HSYNC(1),
        .HBPORCH(1),
        .HSYNC_POSITIVE(1),
        .VSIZE(70),
        .VFPORCH(1),
        .VSYNC(1),
        .VBPORCH(1),
        .VSYNC_POSITIVE(1)
    ) vga_sync(
        .pixel_clk(clk),
        .reset_n(reset_n),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .frame_start(frame_start),
        .line_start(line_start),
        .pixel_visible(pixel_visible)
    );

    vga_console_sync #(
        .TEXT_COLUMNS(5),
        .TEXT_ROWS(3),
        .GLYPH_COLUMNS(11),
        .GLYPH_ROWS(17)
    ) dut1 (
        .pixel_clk(clk),
        .line_start(line_start),
        .frame_start(frame_start),
        .reset_n(reset_n)
    );

    vga_console_sync #(
        .TEXT_COLUMNS(10),
        .TEXT_ROWS(5),
        .GLYPH_COLUMNS(11),
        .GLYPH_ROWS(17)
    ) dut2 (
        .pixel_clk(clk),
        .line_start(line_start),
        .frame_start(frame_start),
        .reset_n(reset_n)
    );

    initial begin
        reset_n = 1'b0;
        repeat(5) @(posedge clk);
        reset_n = 1'b1;
        repeat(30_000) @(posedge clk);
        $finish;
    end

endmodule

