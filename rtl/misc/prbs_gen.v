
//
// Pseudo-Random Binary Sequence generator.
//
// Based on LFSR, x^29 + x^19 + 1.
//
module prbs_gen(
    // Initial out stream bits.
    // Is applied immediately after reset.
    input wire[31:0] seed,
    // Output bit stream.
    output wire out,

    input wire clk,
    input wire reset_n
);
    reg[31:0] flops;
    wire[31:0] next_flops;

    assign next_flops = flops == 32'b0 ? seed
                                       : {flops[30:0], flops[18] ^ flops[28]};

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            flops <= 32'b0;
        end
        else begin
            flops <= next_flops;
        end
    end

    assign out = flops[31];

endmodule

