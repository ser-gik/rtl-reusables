
`timescale 1ns / 100ps

//
// Transmits provided data in UART frame format 8N1,
// (8 data bits, no parity, 1 stop bit).
//
module uart_8n1_transmitter #(
    )(
    // Word to transmit
    input[7:0] trans_data,
    // Should be asserted to initiate send cycle, is ignored
    // if module is in send cycle already
    input trans_write,
    // Is asserted if module is in send cycle
    output reg trans_busy,

    // Outgoing TX line
    output tx,

    // Clock, 16 pulses per 1 baud
    input clk_baud_16x,
    // Should be asserted to reset module on next clock cycle.
    input reset
);
    // Data frame to send
    reg[8:0] frame;
    // State counter, 16 states per each received bit
    reg[7:0] state;

    assign tx = frame[0];

    wire should_start;
    assign should_start = trans_write && !trans_busy;
    wire should_send_next_bit;
    assign should_send_next_bit = state[3:0] == 4'hf;
    wire should_stop;
    assign should_stop = state == 8'h9e;

    always @(posedge clk_baud_16x) begin
        state <= reset || should_start ? 8'b0
                                       : state + 1'b1;
    end

    always @(posedge clk_baud_16x) begin
        if (reset) begin
            frame <= 9'b111111111;
        end
        else if (should_start) begin
            frame <= {trans_data[7:0], 1'b0};
        end
        else if (should_send_next_bit) begin
            frame <= {1'b1, frame[8:1]};
        end
        else begin
            frame <= frame;
        end
    end

    always @(posedge clk_baud_16x) begin
        if (reset || should_stop) begin
            trans_busy <= 1'b0;
        end
        else if (should_start) begin
            trans_busy <= 1'b1;
        end
        else begin
            trans_busy <= trans_busy;
        end
    end
endmodule

