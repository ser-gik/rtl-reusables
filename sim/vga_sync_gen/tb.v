
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
    wire pixel_visible;

    vga_sync_generator #(
        // Use some fake parameters to not slowdown simulation.
        .HSIZE(100),
        .HFPORCH(6),
        .HSYNC(4),
        .HBPORCH(3),
        .HSYNC_POSITIVE(1),
        .VSIZE(70),
        .VFPORCH(5),
        .VSYNC(3),
        .VBPORCH(3),
        .VSYNC_POSITIVE(1)
    ) dut(
        .pixel_clk(clk),
        .reset_n(reset_n),
        .hsync(hsync),
        .vsync(vsync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_visible(pixel_visible)
    );

    initial begin
        reset_n = 1'b0;
        repeat(5) @(posedge clk);
        reset_n = 1'b1;
        repeat(10_000) @(posedge clk);
        $finish;
    end

endmodule

