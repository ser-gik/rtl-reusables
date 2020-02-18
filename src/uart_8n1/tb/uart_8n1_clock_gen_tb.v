
`timescale 1ns / 100ps

`include "../uart_8n1.vh"

module uart_8n1_clock_gen_tb #(
    )(
);
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset;
    reg[1:0] baud_rate;
    wire clk_baud_16x;

    uart_8n1_clock_gen #(
        .SRC_CLK_FREQUENCY(19200 * 16 * 2)
        ) subject(
        .clk_src(clk),
        .baud_rate(baud_rate),
        .clk_baud_16x(clk_baud_16x),
        .reset(reset)
        );

    initial begin
        reset = 1'b1;
        baud_rate = `UART_8N1_BAUD_9600;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        repeat(100) @(posedge clk);
        baud_rate = `UART_8N1_BAUD_19200;
        repeat(100) @(posedge clk);
        baud_rate = `UART_8N1_BAUD_9600;
        repeat(100) @(posedge clk);
        $finish;
    end
endmodule
