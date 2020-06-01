
//
// Converts binary encoded unsigned integer to equivalent BCD representation.
// Output is updated regularly, there is no way to discard current transcoding pass.
//
module binary_to_bcd_transcoder #(
    // Input word size.
    parameter WIDTH = 8,
    // Output word size. User should not change default value as it
    // is derived from input width to fit all output BCD digits.
    parameter OUT_WIDTH = $rtoi($ceil($log10(2 ** WIDTH - 1))) * 4
    )(
    // Input binary data.
    input wire[WIDTH-1:0] in,
    // Output BCD data.
    output wire[OUT_WIDTH-1:0] out,

    input wire clk,
    input wire reset_n
);
    //
    // This module implements "double-dabble" ("shift-and-add-3") algorithm.
    // Refer to any other source for algorithm details.
    //

    function[3:0] add_3_if_5_or_above;
        input[3:0] bcd;
        begin
            case (bcd)
                4'd0: add_3_if_5_or_above = 4'd0;
                4'd1: add_3_if_5_or_above = 4'd1;
                4'd2: add_3_if_5_or_above = 4'd2;
                4'd3: add_3_if_5_or_above = 4'd3;
                4'd4: add_3_if_5_or_above = 4'd4;
                4'd5: add_3_if_5_or_above = 4'd5 + 4'd3;
                4'd6: add_3_if_5_or_above = 4'd6 + 4'd3;
                4'd7: add_3_if_5_or_above = 4'd7 + 4'd3;
                4'd8: add_3_if_5_or_above = 4'd8 + 4'd3;
                4'd9: add_3_if_5_or_above = 4'd9 + 4'd3;
                default: add_3_if_5_or_above = 4'dx;
            endcase
        end
    endfunction

    //
    // One pass finishes in WIDTH cycles, Assign separate state to each cycle
    // and advance unconditionally till the end state will be reached.
    //

    reg[WIDTH-1:0] state;

    localparam STATE_INIT = {{WIDTH-1{1'b0}}, 1'b1};
    localparam STATE_READY = {1'b1, {WIDTH-1{1'b0}}};

    wire ready;
    assign ready = state == STATE_READY;

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            state <= STATE_INIT;
        end
        else begin
            state <= ready ? STATE_INIT : {state[WIDTH-2:0], 1'b0};
        end
    end

    wire restart;
    // Do not stop even if input was not changed.
    assign restart = ready;

    reg[WIDTH-1:0] src_reg;

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            src_reg <= {WIDTH{1'b0}};
        end
        else begin
            src_reg <= restart ? in : {src_reg[WIDTH-2:0], 1'bx};
        end
    end

    reg[OUT_WIDTH-1:0] dst_reg;
    wire[OUT_WIDTH:0] next_dst_reg;

    assign next_dst_reg[0] = src_reg[WIDTH-1];
    genvar i;
    for (i = 0; i < OUT_WIDTH - 4; i = i + 4) begin: next_dst
        assign next_dst_reg[4 + i:1 + i] = add_3_if_5_or_above(dst_reg[3 + i:0 + i]);
    end
    assign next_dst_reg[OUT_WIDTH:OUT_WIDTH-3] = add_3_if_5_or_above(dst_reg[OUT_WIDTH-1:OUT_WIDTH-4]);

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            dst_reg <= {OUT_WIDTH{1'b0}};
        end
        else begin
            dst_reg <= restart ? {OUT_WIDTH{1'b0}} : next_dst_reg[OUT_WIDTH-1:0];
        end
    end

    reg[OUT_WIDTH-1:0] out_reg;

    assign out = out_reg;

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            out_reg <= 1'b0;
        end
        else if (ready) begin
            out_reg <= next_dst_reg[OUT_WIDTH-1:0];
        end
    end

`ifdef REUSABLES_CHECKERS_ENABLED
    `include "std_ovl_defines.h"

    ovl_one_hot #(
        .severity_level(`OVL_ERROR),
        .width(WIDTH),
        .property_type(`OVL_ASSERT),
        .msg("state is not one-hot"),
        .coverage_level(`OVL_COVER_DEFAULT),
        .clock_edge(`OVL_POSEDGE),
        .reset_polarity(`OVL_ACTIVE_LOW),
        .gating_type(`OVL_GATE_NONE)
    ) state_is_one_hot (
        .clock(clk),
        .reset(reset_n),
        .enable(1'b0),
        .test_expr(state),
        .fire()
    );

`endif

endmodule

