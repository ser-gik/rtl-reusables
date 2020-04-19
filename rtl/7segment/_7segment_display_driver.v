
//
// Driver for 7-segment LED block display. Input data are represented
// as a hexadecimal number.
//
module _7segment_display_driver #(
    // Incoming clock line frequency.
    parameter CLK_RATE_HZ = 390625,
    // Width of input data expressed ad a number of 4-bit entities.
    parameter WIDTH_NIBBLES = 6,
    // If clock signal frequency should be divided internally (set to 0 for simulation).
    parameter CLK_DIVIDE = 1
    )(
    // Input data.
    input wire[WIDTH_NIBBLES*4-1:0] data,
    // Control mask to blank separate digits.
    // User should assert bits to enable corresponding digits.
    input wire[WIDTH_NIBBLES-1:0] digit_enable,
    // Control mask to display decimal points.
    // User should assert bits to display decimal point for corresponding digits.
    input wire[WIDTH_NIBBLES-1:0] decimal_point_enable, 

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
    output wire[WIDTH_NIBBLES-1:0] display_segment_enable,

    input wire reset_n,
    input wire clk
);
    wire segment_clk;

    generate
        if (CLK_DIVIDE) begin
            // Divide input clock frequency to get something suitable for refreshing LED digits.
            localparam DISPLAY_REFRESH_RATE_HZ = 80;
            localparam DIGIT_REFRESH_RATE_HZ = DISPLAY_REFRESH_RATE_HZ * WIDTH_NIBBLES;
            // ISE doesn't allow clog2() for localparams
            parameter CLK_DIVIDER_STAGES = $clog2(CLK_RATE_HZ / DIGIT_REFRESH_RATE_HZ) - 1;

            reg[CLK_DIVIDER_STAGES-1:0] div_stages;
            always @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    div_stages <= 1'b0;
                end else begin
                    div_stages <= div_stages + 1'b1;
                end
            end
            assign segment_clk = div_stages[CLK_DIVIDER_STAGES-1];
        end
        else begin
            assign segment_clk = clk;
        end
    endgenerate

    reg[WIDTH_NIBBLES*4-1:0] data_reg;
    reg[WIDTH_NIBBLES-1:0] cur_active;
    reg[7:0] pattern;

    always @(*) begin
        case (data_reg[3:0])
                             // abcdefg  
            4'h0 : pattern = 8'b11111100;
            4'h1 : pattern = 8'b01100000;
            4'h2 : pattern = 8'b11011010;
            4'h3 : pattern = 8'b11110010;
            4'h4 : pattern = 8'b01100110;
            4'h5 : pattern = 8'b10110110;
            4'h6 : pattern = 8'b10111110;
            4'h7 : pattern = 8'b11100000;
            4'h8 : pattern = 8'b11111110;
            4'h9 : pattern = 8'b11110110;
            4'ha : pattern = 8'b11101110;
            4'hb : pattern = 8'b00111110;
            4'hc : pattern = 8'b10011100;
            4'hd : pattern = 8'b01111010;
            4'he : pattern = 8'b10011110;
            4'hf : pattern = 8'b10001110;
        endcase
    end

    always @(posedge segment_clk or negedge reset_n) begin
        if (~reset_n) begin
            data_reg <= data;
            cur_active <= 1'b1;
        end
        else if (~(|cur_active[WIDTH_NIBBLES-2:0])) begin
            data_reg <= data;
            cur_active <= 1'b1;
        end
        else begin
            data_reg <= {{4{1'b0}}, data_reg[WIDTH_NIBBLES*4-1:4]};
            cur_active <= {cur_active[WIDTH_NIBBLES-2:0], 1'b0};
        end
    end

    wire decimal_point;
    assign decimal_point = |(cur_active & decimal_point_enable);

    assign display_segment_enable = cur_active & digit_enable;
    assign display_led_segments = pattern | {{7{1'b0}}, decimal_point};

endmodule
