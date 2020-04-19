
module tb;

    localparam CLK_PERIOD = 2;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset_n;
    reg[2:0] in;
    wire[2:0] out;

    switch_debouncer #(
        .WIDTH(3),
        .SAMPLES_COUNT(5),
        .TICKS_PER_SAMPLE(1)
        ) subject (
        .in(in),
        .out(out),
        .clk(clk),
        .reset_n(reset_n)
        );

    task next_sample;
        input[2:0] value;
        begin
            in = value;
            @(posedge clk);
        end
    endtask

    initial begin
        reset_n = 1'b0;
        repeat(5) @(posedge clk);
        reset_n = 1'b1;

        next_sample(3'b000);
        next_sample(3'b011);
        next_sample(3'b011);
        next_sample(3'b011);
        next_sample(3'b011);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b001);
        next_sample(3'b010);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b010);
        next_sample(3'b010);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        next_sample(3'b101);
        $stop;
    end

endmodule

