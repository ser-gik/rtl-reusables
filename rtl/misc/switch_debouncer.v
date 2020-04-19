
//
// Multi-channel shift register button debouncer.
// Each channel is considered stable if its history consists only of the same samples.
//
module switch_debouncer #(
    // Number of channels to debounce.
    parameter WIDTH = 2,
    // Samples history length.
    parameter SAMPLES_COUNT = 12,
    // sampling interval.
    parameter TICKS_PER_SAMPLE = 1000
    )(
    // Vector to debounce.
    input wire[WIDTH-1:0] in,
    // Debounced.
    output wire[WIDTH-1:0] out,

    input wire clk,
    input wire reset_n
);
    wire sample_clk;

    generate
        if (TICKS_PER_SAMPLE == 1) begin
            assign sample_clk = clk;
        end
        else begin
            localparam TICKS_MAX = TICKS_PER_SAMPLE / 2;
            reg[$clog2(TICKS_MAX)-1:0] ticks;
            reg sample_clk_reg;

            always @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    ticks <= 1'b0;
                    sample_clk_reg <= 1'b0;
                end
                else begin
                    if (ticks == TICKS_MAX) begin
                        ticks <= 1'b0;
                        sample_clk_reg <= ~sample_clk_reg;
                    end
                    else begin
                        ticks <= ticks + 1'b1;
                    end
                end
            end

            assign sample_clk = sample_clk_reg;
        end
    endgenerate

    genvar i;
    for (i = 0; i < WIDTH; i = i + 1) begin: debounce_bit
        reg sync_reg;

        always @(posedge sample_clk) begin
            sync_reg <= in[i];
        end

        reg[SAMPLES_COUNT-1:0] samples;

        always @(posedge sample_clk or negedge reset_n) begin
            if (~reset_n) begin
                samples <= {SAMPLES_COUNT{1'b0}};
            end
            else begin
                samples <= {samples[SAMPLES_COUNT-2:0], sync_reg};
            end
        end

        wire stable_samples;
        reg out_reg;

        assign stable_samples = samples == {SAMPLES_COUNT{1'b0}}
                             || samples == {SAMPLES_COUNT{1'b1}};

        always @(posedge sample_clk or negedge reset_n) begin
            if (~reset_n) begin
                out_reg <= 1'b0;
            end
            else if (stable_samples) begin
                out_reg <= samples[0];
            end
        end

        assign out[i] = out_reg;
    end

endmodule

