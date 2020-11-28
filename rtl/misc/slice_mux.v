
//
// Multiplexer for selecting a slice from input vector.
// Input itself is considered as a tightly packed slices of an equal width.
// Number of slices must be a power of 2.
// Slices are indexed, input bit 0 belongs to slice 0.
//
module slice_mux #(
    // Width of selected slice.
    parameter SLICE_WIDTH = 4,
    // Slice-select bus bits.
    parameter SELECT_BUS_WIDTH = 3
) (
    // Input word.
    input [INPUT_WIDTH-1:0] in,
    // Selected slice index.
    input [SELECT_BUS_WIDTH-1:0] select,
    // Selected slice.
    output [SLICE_WIDTH-1:0] out
);
    localparam INPUT_WIDTH = SLICE_WIDTH * (2 ** SELECT_BUS_WIDTH);

    genvar i;
    generate
        for(i = 0; i < SELECT_BUS_WIDTH; i = i + 1) begin: stage
            localparam STAGE_IN_WIDTH = INPUT_WIDTH / (2 ** i);
            localparam STAGE_OUT_WIDTH = STAGE_IN_WIDTH / 2;

            wire [STAGE_IN_WIDTH-1:0] mux_in;
            wire [STAGE_OUT_WIDTH-1:0] mux_out;

            assign mux_in = i == 0 ? in : stage[i-1].mux_out;
            assign mux_out = select[SELECT_BUS_WIDTH-1-i]
                        ? mux_in[STAGE_IN_WIDTH-1:STAGE_OUT_WIDTH]
                        : mux_in[STAGE_OUT_WIDTH-1:0];
        end
    endgenerate

    assign out = SELECT_BUS_WIDTH != 0 ? stage[SELECT_BUS_WIDTH-1].mux_out : in;

endmodule

