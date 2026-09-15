`timescale 1ns/1ps

module uart_rx #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE     = 115200,
    parameter integer PARITY_MODE   = 0   // 0=None, 1=Even, 2=Odd
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        frame_error,
    output reg        parity_error
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ_HZ / BAUD_RATE;
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;

    reg rx_meta, rx_sync;
    reg [15:0] clk_count;
    reg [3:0]  bit_index;
    reg [7:0]  data_buf;
    reg        parity_bit;
    reg [1:0]  state;

    localparam S_IDLE   = 2'd0;
    localparam S_START  = 2'd1;
    localparam S_DATA   = 2'd2;
    localparam S_PARITY = 2'd3;
    localparam S_STOP   = 2'd4;

    always @(posedge clk) begin
        rx_meta <= rx;
        rx_sync <= rx_meta;
    end

    always @(posedge clk) begin
        if (rst) begin
            data_out    <= 8'h00;
            data_valid  <= 1'b0;
            frame_error <= 1'b0;
            parity_error<= 1'b0;
            clk_count   <= 16'd0;
            bit_index   <= 4'd0;
            data_buf    <= 8'h00;
            parity_bit  <= 1'b0;
            state       <= S_IDLE;
        end else begin
            data_valid   <= 1'b0;
            frame_error  <= 1'b0;
            parity_error <= 1'b0;

            case (state)
                S_IDLE: begin
                    clk_count <= 0;
                    if (!rx_sync)
                        state <= S_START;
                end

                S_START: begin
                    if (clk_count == HALF_BIT-1) begin
                        clk_count <= 0;
                        if (!rx_sync) begin
                            bit_index <= 0;
                            state <= S_DATA;
                        end else begin
                            state <= S_IDLE;
                        end
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                S_DATA: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        data_buf[bit_index] <= rx_sync;
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
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        parity_bit <= rx_sync;
                        if (PARITY_MODE == 1) begin
                            if ((^data_buf) != rx_sync)
                                parity_error <= 1'b1;
                        end else if (PARITY_MODE == 2) begin
                            if ((^data_buf) == rx_sync)
                                parity_error <= 1'b1;
                        end
                        state <= S_STOP;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                S_STOP: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        if (rx_sync) begin
                            data_out   <= data_buf;
                            data_valid <= 1'b1;
                        end else
                            frame_error <= 1'b1;
                        state <= S_IDLE;
                    end else
                        clk_count <= clk_count + 1'b1;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
