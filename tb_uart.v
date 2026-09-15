`timescale 1ns/1ps

module tb_uart;

    localparam integer CLK_HZ = 10_000_000;
    localparam integer BAUD  = 100_000;
    localparam integer CPB   = CLK_HZ / BAUD;

    reg clk = 0;
    reg rst = 1;
    reg rx  = 1;

    wire [7:0] rx_data;
    wire rx_valid, frame_error, parity_error;

    integer errors = 0;
    integer received_count = 0;

    uart_rx #(
        .CLOCK_FREQ_HZ(CLK_HZ),
        .BAUD_RATE(BAUD),
        .PARITY_MODE(0)
    ) dut (
        .clk(clk), .rst(rst), .rx(rx),
        .data_out(rx_data), .data_valid(rx_valid),
        .frame_error(frame_error), .parity_error(parity_error)
    );

    always #50 clk = ~clk; // 10 MHz

    task send_byte;
        input [7:0] b;
        integer i;
        begin
            // Start bit
            rx = 1'b0;
            repeat(CPB) @(posedge clk);
            // 8-N-1, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i];
                repeat(CPB) @(posedge clk);
            end
            // Stop bit
            rx = 1'b1;
            repeat(CPB) @(posedge clk);
        end
    endtask

    always @(posedge clk) begin
        if (rx_valid) begin
            received_count = received_count + 1;
            $display("[%0t] PASS: received 0x%02h", $time, rx_data);
            if (rx_data !== 8'h55 && rx_data !== 8'hA3 && rx_data !== 8'h00)
                errors = errors + 1;
        end
        if (frame_error) begin
            $display("[%0t] FAIL: frame error", $time);
            errors = errors + 1;
        end
        if (parity_error) begin
            $display("[%0t] FAIL: parity error", $time);
            errors = errors + 1;
        end
    end

    initial begin
        $dumpfile("uart_waveform.vcd");
        $dumpvars(0, tb_uart);

        repeat(5) @(posedge clk);
        rst = 0;

        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'h00);

        repeat(CPB*2) @(posedge clk);

        if (received_count == 3 && errors == 0)
            $display("========================================");
        if (received_count == 3 && errors == 0)
            $display("SELF-CHECK: ALL UART TESTS PASSED");
        else begin
            $display("SELF-CHECK: FAILED (received=%0d errors=%0d)",
                     received_count, errors);
            $finish;
        end
        $finish;
    end
endmodule
