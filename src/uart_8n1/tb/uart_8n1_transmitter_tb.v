
`timescale 1ns / 100ps

module uart_8n1_transmitter_tb (
);
    reg reset;
    reg clk;

    reg[7:0] trans_data;
    reg trans_write;
    wire trans_busy;
    wire tx;

    integer i;

    localparam CLK_PERIOD = 4;
    
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;
    initial begin
        reset = 1'b1;
        trans_data = 8'h42;
        trans_write = 1'b0;
        for (i = 0; i < 2; i = i + 1) @(posedge clk);
        reset = 1'b0;
        for (i = 0; i < 2; i = i + 1) @(posedge clk);
        trans_write = 1'b1;
        for (i = 0; i < 400; i = i + 1) @(posedge clk);
        trans_write = 1'b0;
        trans_data = 8'hca;
        for (i = 0; i < 200; i = i + 1) @(posedge clk);
        trans_write = 1'b1;
        for (i = 0; i < 400; i = i + 1) @(posedge clk);
        $finish;
    end

    uart_8n1_transmitter subject(
        .trans_data(trans_data),
        .trans_write(trans_write),
        .trans_busy(trans_busy),
        .tx(tx),
        .clk_baud_16x(clk),
        .reset(reset)
        );
endmodule
