`timescale 1ns/1ps

module uart_tx #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE     = 115200,
    parameter integer PARITY_MODE   = 0   // 0=None, 1=Even, 2=Odd
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] data_in,
    input  wire       start,
    output reg        tx,
    output reg        busy,
    output reg        done
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ_HZ / BAUD_RATE;

    reg [15:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_buf;
    reg        parity_bit;
    reg [2:0]  state;

    localparam S_IDLE   = 3'd0;
    localparam S_START  = 3'd1;
    localparam S_DATA   = 3'd2;
    localparam S_PARITY = 3'd3;
    localparam S_STOP   = 3'd4;

    always @(posedge clk) begin
        if (rst) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
            data_buf  <= 0;
            parity_bit<= 0;
            state     <= S_IDLE;
        end else begin
            done <= 1'b0;

            case (state)
                S_IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 0;
                    if (start) begin
                        data_buf   <= data_in;
                        parity_bit <= (PARITY_MODE == 1) ? ~(^data_in) :
                                      (PARITY_MODE == 2) ?  (^data_in) : 1'b0;
                        bit_index  <= 0;
                        busy       <= 1'b1;
                        state      <= S_START;
                    end
                end

                S_START: begin
                    tx <= 1'b0;
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        state <= S_DATA;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                S_DATA: begin
                    tx <= data_buf[bit_index];
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        if (bit_index == 7) begin
                            if (PARITY_MODE == 0)
                                state <= S_STOP;
                            else
                                state <= S_PARITY;
                        end else
                            bit_index <= bit_index + 1'b1;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                S_PARITY: begin
                    tx <= parity_bit;
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        state <= S_STOP;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                S_STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        busy <= 1'b0;
                        done <= 1'b1;
                        state <= S_IDLE;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
