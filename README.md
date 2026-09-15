# FPGA-Based UART Transceiver Design

A synthesizable Verilog HDL UART transmitter/receiver project designed for FPGA-based asynchronous serial communication.

## Project objective

This project implements:
- UART transmitter and receiver
- Configurable clock frequency and baud rate through Verilog parameters
- Optional parity: none, even, or odd
- 8-bit data, LSB first
- One stop bit
- Receiver start-bit validation
- Frame-error and parity-error reporting
- Self-checking simulation testbench
- Basys 3 / Artix-7 example constraints

## Repository structure

```text
FPGA_UART_Transceiver/
├── src/
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_top.v
├── tb/
│   └── tb_uart.v
├── constraints/
│   └── basys3_uart.xdc
├── simulation/
│   └── simulation_result.txt
├── docs/
│   └── block_diagram.svg
└── README.md
```

## UART configuration

Default example:
- FPGA clock: 100 MHz
- Baud rate: 115200
- Data: 8 bits
- Stop: 1 bit
- Default parity: none

The baud rate and clock frequency are parameters, so the same RTL can be reused with other clock/baud combinations.

## Simulation

The supplied testbench uses a smaller 10 MHz clock and 100 kbaud so simulation runs quickly. It sends:
- `0x55`
- `0xA3`
- `0x00`

The testbench is self-checking and generates a VCD waveform.

### Icarus Verilog

```bash
iverilog -g2012 -o uart_sim src/uart_rx.v src/uart_tx.v src/uart_top.v tb/tb_uart.v
vvp uart_sim
```

For waveform viewing:

```bash
gtkwave uart_waveform.vcd
```

### Vivado / ModelSim

Add the files under `src/` as design sources and `tb/tb_uart.v` as a simulation source. Run behavioral simulation and inspect `rx`, `rx_data`, `rx_valid`, `frame_error`, and `parity_error`.

## FPGA implementation

The `constraints/basys3_uart.xdc` file provides an example for a Digilent Basys 3 / Artix-7 board. **Verify the UART pin mapping against your exact board documentation before programming hardware.**

For a PC terminal, configure the terminal to match the RTL baud/parity/data/stop settings.

## Important engineering note

The RTL and testbench are provided as a portfolio-ready starting project. The repository should only claim synthesis, timing closure, and physical FPGA validation after those steps have actually been run on the target board.



> Designed and verified a parameterized FPGA-based UART transceiver in Verilog HDL, supporting configurable baud rates, optional parity, start/stop framing, self-checking simulation, and FPGA-oriented timing/constraint analysis.

## License

Use or modify for personal portfolio/learning purposes.
