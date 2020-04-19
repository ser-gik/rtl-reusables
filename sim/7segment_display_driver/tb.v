
module tb;

    wire[7:0] display_led_segments;
    wire[5:0] display_segment_enable;

    reg reset_n;
    reg clk;

    localparam CLK_PERIOD = 4;
    
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;
    initial begin
        reset_n = 1'b0;
        @(posedge clk);
        @(posedge clk);
        reset_n = 1'b1;
    end

    initial #100 $stop;

    _7segment_display_driver #(
        .CLK_RATE_HZ(10000),
        .CLK_DIVIDE(0)
        ) subject (
        .data(24'h12_34_56), 
        .digit_enable(6'b111111), 
        .decimal_point_enable(6'b010101),
        .display_led_segments(display_led_segments), 
        .display_segment_enable(display_segment_enable), 
        .reset_n(reset_n), 
        .clk(clk)
        );
endmodule

