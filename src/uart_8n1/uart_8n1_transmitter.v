
`timescale 1ns / 100ps

module uart_8n1_transmitter #(
    )(
    input[7:0] trans_data,
    input trans_write,
    output reg trans_busy,

    output tx,

    input clk_baud_16x,
    input reset
);
    reg[8:0] frame;
    reg[7:0] counter;

    always @(posedge clk_baud_16x) begin
        if (reset || (trans_write && !trans_busy)) begin
            counter <= 8'b0;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    always @(posedge clk_baud_16x) begin
        if (reset) begin
            frame <= 9'b111111111;
        end
        else if (trans_write && !trans_busy) begin
            frame <= {trans_data[7:0], 1'b0};
        end
        else if (counter[3:0] == 4'hf) begin
            frame <= {1'b1, frame[8:1]};
        end
        else begin
            frame <= frame;
        end
    end

    always @(posedge clk_baud_16x) begin
        if (reset) begin
            trans_busy <= 1'b0;
        end
        else if (trans_write && !trans_busy) begin
            trans_busy <= 1'b1;
        end
        else if (counter == 8'h9e) begin
            trans_busy <= 1'b0;
        end
        else begin
            trans_busy <= trans_busy;
        end
    end

    assign tx = frame[0];

endmodule

