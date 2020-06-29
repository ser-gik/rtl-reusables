
`include "reusables.vh"

//
// Generalized register to be used by all other components instead of
// inferencing from behavioral descriptions.
//
// It is an edge-triggered flip-flop of arbitrary width with a reset input.
// There are three macros that control this module (and therefore all other
// design modules that utilize it).
//
// REUSABLES_REG_CLK_RISING - non-zero value means that register stores its
// input on rising clock edge, otherwise - on negative.
// REUSABLES_REG_RESET_ACTIVE_HIGH - non-zero value means that register is
// cleared to all-zeros if reset input is 1'b1, and vice-versa.
// REUSABLES_REG_RESET_SYNC - non-zero value means that active reset signal
// will be applied only on next active clock edge, otherwise it is applied
// immediately.
//
module r_reg #(
    parameter W = 1
    )(
    output [W-1:0] q,
    input [W-1:0] d,
    input clk,
    input reset
);
    reg[W-1:0] ff;
    wire clk_rising;
    wire reset_high;

    assign q = ff;

`ifndef REUSABLES_REG_CLK_RISING
    `R_STATIC_ERROR(missing_clock_polarity_spec);
`else
    generate
        if (`REUSABLES_REG_CLK_RISING) begin
            assign clk_rising = clk;
        end
        else begin
            assign clk_rising = ~clk;
        end
    endgenerate
`endif

`ifndef REUSABLES_REG_RESET_ACTIVE_HIGH
    `R_STATIC_ERROR(missing_reset_polarity_spec);
`else
    generate
        if (`REUSABLES_REG_RESET_ACTIVE_HIGH) begin
            assign reset_high = reset;
        end
        else begin
            assign reset_high = ~reset;
        end
    endgenerate
`endif

`ifndef REUSABLES_REG_RESET_SYNC
    `R_STATIC_ERROR(missing_reset_behavior_spec);
`else
    generate
        if (`REUSABLES_REG_RESET_SYNC) begin
            always @(posedge clk_rising) begin
                if (reset_high) begin
                    ff <= {W{1'b0}};
                end
                else begin
                    ff <= d;
                end
            end
        end
        else begin
            always @(posedge clk_rising or posedge reset_high) begin
                if (reset_high) begin
                    ff <= {W{1'b0}};
                end
                else begin
                    ff <= d;
                end
            end
        end
    endgenerate
`endif

endmodule

