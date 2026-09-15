## Basys 3 / Artix-7 XC7A35T-1CPG236C
## 100 MHz system clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## USB-UART RX/TX pins for the Basys 3 onboard interface.
## Verify pin mapping against your board revision before programming.
set_property PACKAGE_PIN B18 [get_ports uart_rx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property PACKAGE_PIN A18 [get_ports uart_tx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]

set_property PACKAGE_PIN V17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
