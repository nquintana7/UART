# Simple VHDL UART interface for FPGA

## Description
It is a very simple implementation, 8 data bits, no parity bit, 1 stop bit.
It was tested with a clock input of 100Mhz and 115200 baudrate.

It was tested on a simple simulation testbench and then run on an Arty A7-35 board, as a loopback connecting rx and tx to the other, it sends back the received data.