
module tb;

    localparam CLK_PERIOD = 2;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset_n;
    wire out;

    prbs_gen subject(
        .seed(32'hcafe_babe),
        .out(out),
        .clk(clk),
        .reset_n(reset_n)
        );

    initial begin
        reset_n = 1'b0;
        repeat(5) @(posedge clk);
        reset_n = 1'b1;
        repeat(10000) @(posedge clk);
        $stop;
    end

endmodule

