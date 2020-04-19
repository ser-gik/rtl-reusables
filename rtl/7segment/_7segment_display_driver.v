`timescale 1ns/100ps

//
// Driver for 7-segment LED block display. Input data are represented
// as a hexadecimal number.
//
module _7segment_display_driver #(
    // Incoming clock line frequency.
    parameter CLK_RATE_HZ = 390625,
    // Width of input data expressed ad a number of 4-bit entities.
    parameter WIDTH_NIBBLES = 6
    )(
    // Input data.
    input wire[WIDTH_NIBBLES*4-1:0] data,
    // Control mask to blank separate digits.
    // User should assert bits to enable corresponding digits.
    input wire[WIDTH_NIBBLES-1:0] digit_enable_mask,
    // Control mask to display decimal points.
    // User should assert bits to display decimal point for corresponding digits.
    input wire[WIDTH_NIBBLES-1:0] decimal_point_enable_mask, 

    // LED block segments bus.
    // Bits are arranged in the following order: a-b-c-d-e-f-g-dp, where 'a' is a bit 7
    // and 'dp' is a bit 0, assuming that display segment layout is next:
    //
    //       /-a-/
    //      f   b
    //     /-g-/
    //    e   c
    //   /-d-/  dp
    //
    // Asserting any bit should turn on corresponding segment and vice versa.
    output wire[7:0] display_led_segments,
    // LED block digit select mask. Highest mask bit corresponds to highest input
    // data nibble and so on.
    // Asserting any bit should turn on corresponding block digit.
    output wire[WIDTH_NIBBLES-1:0] display_led_enable_mask,

    input wire reset,
    input wire clk
);
    // Divide input clock frequency to get something suitable for refreshing LED digits.
    localparam DISPLAY_REFRESH_RATE_HZ = 80;
    localparam DIGIT_REFRESH_RATE_HZ = DISPLAY_REFRESH_RATE_HZ * WIDTH_NIBBLES;
    // ISE doesn't allow clog2() for localparams
    parameter CLK_DIVIDER_STAGES = $clog2(CLK_RATE_HZ / DIGIT_REFRESH_RATE_HZ) - 1;

    reg[CLK_DIVIDER_STAGES-1:0] div_stages;
    always @(posedge clk) begin
        if (reset) begin
            div_stages <= 1'b0;
        end else begin
            div_stages <= div_stages + 1'b1;
        end
    end
    wire block_clk;
    assign block_clk = div_stages[CLK_DIVIDER_STAGES-1];

    function[7:0] nibble_to_7seg;
        input[3:0] nibble;
        begin
                                              // abcdefg  
            nibble_to_7seg = nibble == 4'h0 ? 8'b11111100 :
                             nibble == 4'h1 ? 8'b01100000 :
                             nibble == 4'h2 ? 8'b11011010 :
                             nibble == 4'h3 ? 8'b11110010 :
                             nibble == 4'h4 ? 8'b01100110 :
                             nibble == 4'h5 ? 8'b10110110 :
                             nibble == 4'h6 ? 8'b10111110 :
                             nibble == 4'h7 ? 8'b11100000 :
                             nibble == 4'h8 ? 8'b11111110 :
                             nibble == 4'h9 ? 8'b11110110 :
                             nibble == 4'ha ? 8'b11101110 :
                             nibble == 4'hb ? 8'b00111110 :
                             nibble == 4'hc ? 8'b10011100 :
                             nibble == 4'hd ? 8'b01111010 :
                             nibble == 4'he ? 8'b10011110 :
                             nibble == 4'hf ? 8'b10001110 :
                                              8'bxxxxxxxx;
        end
    endfunction

    reg[WIDTH_NIBBLES*4-1:0] data_latch;
    reg[WIDTH_NIBBLES-1:0] cur_active_mask;

    assign display_led_enable_mask = cur_active_mask & digit_enable_mask;
    assign display_led_segments = nibble_to_7seg(data_latch[3:0])
                        | (|(cur_active_mask & decimal_point_enable_mask));

    always @(posedge block_clk) begin
        if (!(|cur_active_mask[WIDTH_NIBBLES-2:0]) || reset) begin
            data_latch <= data;
            cur_active_mask <= 1'b1;
        end else begin
            data_latch <= data_latch >> 4;
            cur_active_mask <= cur_active_mask << 1;
        end
    end
endmodule
