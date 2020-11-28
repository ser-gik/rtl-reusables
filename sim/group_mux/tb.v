
`timescale 1ns/100ps

module tb;

    localparam CLK_PERIOD = 2;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg [2:0] select1;
    wire [7:0] out1;
    slice_mux #(
        .SLICE_WIDTH(8),
        .SELECT_BUS_WIDTH(3)
    ) uut (
        .in(64'h0123_4567_89ab_cdef),
        .select(select1),
        .out(out1)
    );

    reg [-1:0] select2;
    wire [7:0] out2;
    slice_mux #(
        .SLICE_WIDTH(8),
        .SELECT_BUS_WIDTH(0)
    ) uut2 (
        .in(8'h5a),
        .select(select2),
        .out(out2)
    );

    integer i;

    initial begin
        select1 = 3'b0;
        @(posedge clk);
        for(i = 0; i < 8; i = i + 1) begin
            select1 = select1 + 1'b1;
            @(posedge clk);
        end
        $finish;
    end

endmodule

