# ECC Memory Controller

## Description

The ECC Memory Controller is a digital system design project implemented using Verilog HDL.

ECC (Error Correcting Code) is used to detect and correct errors in stored memory data. This project uses Hamming (12,8) ECC to protect 8-bit data.

The controller can detect and correct a single-bit error during a read operation.

## Features

- 8-bit data input
- Hamming (12,8) ECC
- Single-bit error detection
- Single-bit error correction
- Memory write and read operations
- Error indication
- Verilog HDL implementation
- Testbench included
- Simulation waveform support

## Hamming (12,8)

The 12-bit ECC code contains:

- 8 data bits
- 4 parity bits

Parity bits are located at positions:

```text
1, 2, 4, 8