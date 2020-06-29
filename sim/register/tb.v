
`timescale 1ns/1ns

module tb;
    localparam CLK_PERIOD = 2;

    reg clk;
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    reg reset;
    initial begin
        reset = 1'b1;
        repeat(5) @(posedge clk);
        reset = 1'b0;
    end

    reg d;
    initial begin
        d = 1'b0;
        repeat(10) begin
            @(negedge clk);
            @(negedge clk);
            d = 1'b1;
            @(negedge clk);
            @(negedge clk);
            d = 1'b0;
            @(negedge clk);
            @(negedge clk);
            d = 1'bx;
        end
        $finish();
    end

    r_reg r_reg_inst(
        .q(),
        .d(d),
        .clk(clk),
        .reset(reset)
    );
endmodule

