
`timescale 1ns / 100ps

module uart_8n1_receiver_tb #(
    )(
);
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    wire[7:0] recv_data;
    reg recv_read;
    wire recv_busy;
    wire recv_error;
    reg[9:0] rx_data;
    wire rx;
    assign rx = rx_data[0];
    reg reset;

    uart_8n1_receiver subject(
        .recv_data(recv_data),
        .recv_read(recv_read),
        .recv_busy(recv_busy),
        .recv_error(recv_error),
        .rx(rx),
        .clk_baud_16x(clk),
        .reset(reset)
        );

    integer i;

    initial begin
        reset = 1'b1;
        rx_data = 10'b1111111111;
        recv_read = 1'b0;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        recv_read = 1'b1;
        repeat(40) @(posedge clk);

        rx_data = {1'b1, 8'h56, 1'b0};
        for (i = 0; i < 9; i = i + 1) begin
            repeat(16) @(posedge clk);
            rx_data = rx_data >> 1;
        end
        repeat(40) @(posedge clk);
        
        rx_data = {1'b1, 8'h77, 1'b0};
        for (i = 0; i < 9; i = i + 1) begin
            repeat(16) @(posedge clk);
            rx_data = rx_data >> 1;
        end
        repeat(40) @(posedge clk);

        rx_data = 10'b0;
        repeat(1) @(posedge clk);
        rx_data = 10'b1;
        repeat(40) @(posedge clk);

        rx_data = 10'b0;
        repeat(5) @(posedge clk);
        rx_data = 10'b1;
        repeat(40) @(posedge clk);

        rx_data = {1'b1, 8'hab, 1'b0};
        for (i = 0; i < 9; i = i + 1) begin
            repeat(16) @(posedge clk);
            rx_data = rx_data >> 1;
        end
        repeat(16) @(posedge clk);
        rx_data = {1'b1, 8'hfe, 1'b0};
        for (i = 0; i < 9; i = i + 1) begin
            repeat(16) @(posedge clk);
            rx_data = rx_data >> 1;
        end
        recv_read = 1'b0;
        repeat(100) @(posedge clk);

        $finish;
    end
endmodule
