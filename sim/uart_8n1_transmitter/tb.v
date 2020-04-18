
`timescale 1ns / 100ps

module tb;
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg[7:0] trans_data;
    reg trans_write;
    wire trans_busy;
    wire tx;
    reg reset;

    uart_8n1_transmitter subject(
        .trans_data(trans_data),
        .trans_write(trans_write),
        .trans_busy(trans_busy),
        .tx(tx),
        .clk_baud_16x(clk),
        .reset(reset)
        );

    initial begin
        reset = 1'b1;
        trans_data = 8'h42;
        trans_write = 1'b0;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        repeat(2) @(posedge clk);
        trans_write = 1'b1;
        repeat(400) @(posedge clk);
        trans_write = 1'b0;
        trans_data = 8'hca;
        repeat(200) @(posedge clk);
        trans_write = 1'b1;
        repeat(400) @(posedge clk);
        trans_write = 1'b0;
        repeat(1000) @(posedge clk);
        $finish;
    end
endmodule
