`timescale 1ns / 100ps

module led_display_driver_tb();

    wire[7:0] display_led_segments;
    wire[5:0] display_led_enable_mask;

    reg reset;
    reg clk;

    localparam CLK_PERIOD = 4;
    
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;
    initial begin
        reset = 1'b1;
        @(posedge clk);
        @(posedge clk);
        forever #1 reset = 1'b0;
    end

    initial #5000 $finish;

    led_display_driver #(.CLK_RATE_HZ(10000)) subject (
        .data(24'h12_34_56), 
        .digit_enable_mask(6'b111111), 
        .decimal_point_enable_mask(6'b010101),
        .display_led_segments(display_led_segments), 
        .display_led_enable_mask(display_led_enable_mask), 
        .reset(reset), 
        .clk(clk)
        );
endmodule

