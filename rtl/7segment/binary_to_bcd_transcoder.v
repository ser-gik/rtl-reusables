
module binary_to_bcd_transcoder #(
    parameter WIDTH = 8,
    parameter OUT_WIDTH = $rtoi($ceil($log10(2 ** WIDTH - 1))) * 4
    )(
    input wire[WIDTH-1:0] in,
    output wire[OUT_WIDTH-1:0] out,

    input wire clk,
    input wire reset_n
);
    function[3:0] split;
        input[3:0] bcd;
        begin
            case (bcd)
                4'd0: split = 4'd0;
                4'd1: split = 4'd1;
                4'd2: split = 4'd2;
                4'd3: split = 4'd3;
                4'd4: split = 4'd4;
                4'd5: split = 4'd5 + 4'd3;
                4'd6: split = 4'd6 + 4'd3;
                4'd7: split = 4'd7 + 4'd3;
                4'd8: split = 4'd8 + 4'd3;
                4'd9: split = 4'd9 + 4'd3;
                default: split = 4'dx;
            endcase
        end
    endfunction


    reg[$clog2(WIDTH)-1:0] state;

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            state <= 1'b0;
        end
        else begin
            state <= state != WIDTH - 1 ? state + 1'b1 : 1'b0;
        end
    end

    wire ready;
    assign ready = state == WIDTH - 1;
    wire restart;
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
        assign next_dst_reg[4 + i:1 + i] = split(dst_reg[3 + i:0 + i]);
    end
    assign next_dst_reg[OUT_WIDTH:OUT_WIDTH-3] = split(dst_reg[OUT_WIDTH-1:OUT_WIDTH-4]);

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

endmodule

