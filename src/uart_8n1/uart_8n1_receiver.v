
`timescale 1ns / 100ps

//
// Receives data in an UART frame format 8N1,
// (8 data bits, no parity, 1 stop bit).
//
module uart_8n1_receiver #(
    )(
    // Received word
    output reg[7:0] recv_data,
    // Should be asserted to start receive cycle on next clock,
    // is ignored when module is in receive cycle
    input recv_read,
    // Is asserted when module is in receive cycle,
    // received word is updated during negative edge
    output reg recv_busy,
    // Is asserted if error condition was detected, whether it is
    // a sampling failure or rx line break
    output reg recv_error,

    // External RX line
    input rx,

    // Clock, 16 pulses per 1 baud
    input clk_baud_16x,
    // Should be asserted to reset module on next clock cycle
    input reset,
);
    // RX synchronized to our clock
    reg rx_sync;
    always @(posedge clk_baud_16x) begin
        rx_sync <= rx;
    end

    // State counter, upper 4 bits are an index of current bit,
    // lower 4 bits are intermediate states within one bit
    reg[7:0] state

    wire is_start_bit;
    assign is_start_bit = state[7:4] == 4'h0;
    wire is_stop_bit;
    assign is_stop_bit = state[7:4] == 4'h9;
    wire is_data_bit;
    assign is_data_bit = !is_start_bit && !is_stop_bit;

    // Currently sampled bit
    // Sampling occurs on transitions to interm state 4. Then,
    // on transitions to states 8 and 12 it is rechecked to
    // match already sampled level.
    reg sample;
    always @(posedge clk_baud_16x) begin
        sample <= state[3:0] == 4'h3 ? rx_sync : sample;
    end
    
    wire sampling_error;
    assign sampling_error = (state[3:0] == 4'h7 || state[3:0] == 4'hb)
                            && (sample != rx_sync);
    wire is_sampled;
    assign is_sampled = state[3:0] == 4'hb && !sampling_error;

    // Assert error if sampling was failed or wrong start / stop bits
    // were received
    wire framing_error;
    assign framing_error = (is_start_bit && is_sampled && sample == 1'b1)
                        || (is_stop_bit && is_sampled && sample == 1'b0);
    always @(posedge clk_baud_16x) begin
        if (reset || (recv_read && !recv_busy)) begin
            recv_error <= 1'b0;
        end
        else begin
            recv_error <= sampling_error || framing_error;
        end
    end

    wire cycle_finish;
    assign cycle_finish = is_stop_bit && state[3:0] == 4'he;
    always @(posedge clk_baud_16x) begin
        if (reset) begin
            recv_busy <= 1'b0;
        end
        else begin
            if (recv_busy) begin
                recv_busy <= sampling_error || framing_error || cycle_finish ?
                             1'b0 : recv_busy;
            end
            else begin
                recv_busy <= recv_read ? 1'b1 : recv_busy;
            end
        end
    end

    reg[7:0] accumulator;
    always @(posedge clk_baud_16x) begin
        if (is_data_bit && is_sampled) begin
            accumulator <= {sample, accumulator[7:1]};
        end
        else begin
            accumulator <= accumulator;
        end
    end
    
    always @(posedge clk_baud_16x) begin
        recv_data <= cycle_finish ? accumulator : recv_data;
    end
    




    always @(posedge clk_baud_16x) begin
        if (reset) begin
            state <= 8'b0;
        end
        else begin
            if (recv_busy) begin
                
            end
            else begin

            end
        end
    end

endmodule
