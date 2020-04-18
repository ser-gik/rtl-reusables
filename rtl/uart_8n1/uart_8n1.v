
`timescale 1ns / 100ps

module uart_8n1 #(
    parameter CLK_FREQUENCY = 1_000_000
    )(
    input[1:0] baud_rate,

    input[7:0] tx_data,
    output tx_full,
    output tx_empty,
    input tx_write,

    output[7:0] rx_data,
    output rx_full,
    output rx_empty,
    output rx_error,
    input rx_read,

    output tx,
    input rx,

    input clk,
    input reset
);
    wire clk_baud_16x;

    uart_8n1_clock_gen #(
        .SRC_CLK_FREQUENCY(CLK_FREQUENCY)
        ) clock_generator(
        .clk_src(clk),
        .baud_rate(baud_rate),
        .clk_baud_16x(clk_baud_16x),
        .reset(reset)
        );

    reg reset_sticky;
    reg prev_clk_baud_16x;
    always @(posedge clk) begin
        prev_clk_baud_16x <= clk_baud_16x;
        if (reset) begin
            reset_sticky <= 1'b1;
        end
        else if (reset_sticky && !prev_clk_baud_16x && clk_baud_16x) begin
            reset_sticky <= 1'b0;
        end
    end

    wire transmitter_busy;
    reg prev_transmitter_busy;
    reg has_outgoing;
    reg[7:0] outgoing;

    assign tx_full = has_outgoing;
    assign tx_empty = !has_outgoing;

    always @(posedge clk) begin
        if (reset) begin
            has_outgoing <= 1'b0;
            prev_transmitter_busy <= 1'b0;
        end
        else begin
            prev_transmitter_busy <= transmitter_busy;
            if (has_outgoing) begin
                if (!prev_transmitter_busy && transmitter_busy) begin
                    has_outgoing <= 1'b0;
                end
            end
            else if (tx_write) begin
                outgoing <= tx_data;
                has_outgoing <= 1'b1;
            end
        end
    end

    uart_8n1_transmitter transmitter(
        .trans_data(outgoing),
        .trans_write(has_outgoing),
        .trans_busy(transmitter_busy),
        .tx(tx),
        .clk_baud_16x(clk_baud_16x),
        .reset(reset_sticky)
        );


    wire receiver_busy;
    reg prev_receiver_busy;
    reg has_incoming;

    assign rx_full = has_incoming;
    assign rx_empty = !has_incoming;

    always @(posedge clk) begin
        if (reset) begin
            has_incoming <= 1'b0;
            prev_receiver_busy <= 1'b0;
        end
        else begin
            prev_receiver_busy <= receiver_busy;
            if (has_incoming) begin
                has_incoming <= 1'b0;
            end
            else if (prev_receiver_busy && !receiver_busy && !rx_error) begin
                has_incoming <= 1'b1;
            end
        end
    end

    uart_8n1_receiver receiver(
        .recv_data(rx_data),
        .recv_read(rx_read),
        .recv_busy(receiver_busy),
        .recv_error(rx_error),
        .rx(rx),
        .clk_baud_16x(clk_baud_16x),
        .reset(reset_sticky)
        );
endmodule
