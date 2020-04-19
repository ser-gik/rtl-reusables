
module tb;

    localparam CLK_PERIOD = 2;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset_n;
    reg[15:0] in;
    wire[19:0] out;

    binary_to_bcd_transcoder #(
        .WIDTH(16)
        ) subject (
        .in(in),
        .out(out),
        .clk(clk),
        .reset_n(reset_n)
    );

    genvar i;
    for (i = 2; i < 32; i = i + 1) begin: transcoder
        binary_to_bcd_transcoder #(
            .WIDTH(i)
            ) subject (
            .in(),
            .out(),
            .clk(clk),
            .reset_n(reset_n)
        );
        initial $display("bin: %d, dec: %d", subject.WIDTH, subject.OUT_WIDTH / 4);
    end

    initial begin
        reset_n = 1'b0;
        repeat(4) @(posedge clk);
        reset_n = 1'b1;

        in = 16'd12345;
        repeat(20) @(posedge clk);
        in = 16'd9876;
        repeat(20) @(posedge clk);
        in = 16'd0;
        repeat(20) @(posedge clk);
        in = 16'hffff;
        repeat(50) @(posedge clk);

        $stop;
    end

endmodule

