
`timescale 1ns / 100ps

`include "uart_8n1.vh"

module tb;
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg[8:0] outgoing;
    wire[7:0] incoming;
    wire tx_full;
    reg tx_write;
    wire rx_full;
    wire rx_error;

    wire line;

    reg reset;

    uart_8n1 #(
        .CLK_FREQUENCY(19200 * 16 * 2)
    ) subject(
    .baud_rate(`UART_8N1_BAUD_9600),
    .tx_data(outgoing[7:0]),
    .tx_full(tx_full),
    .tx_empty(),
    .tx_write(tx_write),
    .rx_data(incoming),
    .rx_full(rx_full),
    .rx_empty(),
    .rx_error(rx_error),
    .rx_read(1'b1),

    .tx(line),
    .rx(line),

    .clk(clk),
    .reset(reset)
    );
    
    initial begin
        reset = 1'b1;
        tx_write = 1'b0;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        for (outgoing = 9'b0; outgoing <= 9'hff; outgoing = outgoing + 1'b1) begin
            tx_write = 1'b1;
            wait (tx_full);
            tx_write = 1'b0;
            wait (!tx_full);
        end
        repeat(400) @(posedge clk);
        $finish;
    end
endmodule

