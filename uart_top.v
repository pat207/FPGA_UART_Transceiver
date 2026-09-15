`timescale 1ns/1ps

module uart_top #(
    parameter integer CLOCK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE     = 115200,
    parameter integer PARITY_MODE   = 0
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       uart_rx_pin,
    output wire       uart_tx_pin,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_frame_error,
    output wire       rx_parity_error
);

    wire tx_busy;
    wire tx_done;

    // Loopback/demo configuration:
    // Received bytes are exposed through rx_data/rx_valid.
    // The TX interface can be extended from this top-level wrapper.
    uart_rx #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .PARITY_MODE(PARITY_MODE)
    ) u_rx (
        .clk(clk), .rst(rst), .rx(uart_rx_pin),
        .data_out(rx_data), .data_valid(rx_valid),
        .frame_error(rx_frame_error), .parity_error(rx_parity_error)
    );

    uart_tx #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE),
        .PARITY_MODE(PARITY_MODE)
    ) u_tx (
        .clk(clk), .rst(rst), .data_in(8'h00), .start(1'b0),
        .tx(uart_tx_pin), .busy(tx_busy), .done(tx_done)
    );
endmodule
