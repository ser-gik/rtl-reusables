
`timescale 1ns / 100ps

`include "uart_8n1.vh"

module uart_8n1_clock_gen #(
    parameter SRC_CLK_FREQUENCY = 1_000_000
    )(
    input clk_src,
    input[1:0] baud_rate,
    output reg clk_baud_16x,
    input reset
);
    //
    // Baud 16x signal is obtained via plain counter division.
    // Thus it is not necessarily possible to always obtain
    // a frequency that matches to standard baud rates precisely.
    // Here we define a maximal allowed frequency mismatch
    // and derive appropriate dividers.
    //
    localparam real MAX_FREQ_ERROR = 0.005; // 0.5%

    localparam real B_9K6_TOGGLE_FREQ = 9600 * 16.0 * 2.0;
    localparam real B_19K2_TOGGLE_FREQ = 19200 * 16.0 * 2.0;

    localparam real B_9K6_SCALE = 1.0 * SRC_CLK_FREQUENCY / B_9K6_TOGGLE_FREQ;
    localparam real B_19K2_SCALE = 1.0 * SRC_CLK_FREQUENCY / B_19K2_TOGGLE_FREQ;

    localparam integer B_9K6_DIVIDER = B_9K6_SCALE;
    localparam integer B_19K2_DIVIDER = B_19K2_SCALE;

    localparam real B_9K6_FREQ_RATIO = 1.0 * B_9K6_DIVIDER / B_9K6_SCALE;
    localparam real B_19K2_FREQ_RATIO = 1.0 * B_19K2_DIVIDER / B_19K2_SCALE;

    localparam real B_9K6_FREQ_ERROR = (B_9K6_FREQ_RATIO > 1.0 ?
                B_9K6_FREQ_RATIO - 1.0 : 1.0 - B_9K6_FREQ_RATIO);
    localparam real B_19K2_FREQ_ERROR = (B_19K2_FREQ_RATIO > 1.0 ?
                B_19K2_FREQ_RATIO - 1.0 : 1.0 - B_19K2_FREQ_RATIO);

    generate
        if (B_9K6_FREQ_ERROR > MAX_FREQ_ERROR) begin
            no_precise_divider_for_baud_9600__change_src_clk_freq fatal();
        end
        if (B_19K2_FREQ_ERROR > MAX_FREQ_ERROR) begin
            no_precise_divider_for_baud_19200__change_src_clk_freq fatal();
        end
    endgenerate

    // Use registers wide enough to fit the largest divider
    reg[$clog2(B_9K6_DIVIDER):0] next_threshold;
    always @(*) begin
        case (baud_rate)
            `UART_8N1_BAUD_9600 : next_threshold = B_9K6_DIVIDER - 1'b1;
            `UART_8N1_BAUD_19200 : next_threshold = B_19K2_DIVIDER - 1'b1;
            default : next_threshold = 1'b0;
        endcase
    end

    reg[$clog2(B_9K6_DIVIDER):0] counter; 
    reg[$clog2(B_9K6_DIVIDER):0] threshold;
    always @(posedge clk_src) begin
        if (reset) begin
            clk_baud_16x <= 1'b0;
            counter <= 1'b0;
            threshold <= 1'b0;
        end
        else begin
            if (counter == threshold) begin
                clk_baud_16x <= ~clk_baud_16x;
                counter <= 1'b0;
                threshold <= next_threshold;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
