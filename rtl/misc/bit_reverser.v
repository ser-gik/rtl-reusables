//
// Flips order of lines in provided bus.
//
module bit_reverser #(
    parameter WIDTH = 4
)(
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);
    genvar i;
    for (i = 0; i < WIDTH; i = i + 1) begin
        assign out[i] = in[WIDTH - 1 - i];
    end
endmodule

