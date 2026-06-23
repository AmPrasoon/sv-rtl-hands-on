# AXI-Style Synchronous FIFO

This exercise implements a small parameterized synchronous FIFO using an AXI4-Stream-style valid/ready handshake.

## Goal

To implement a compact but realistic RTL block that includes:

- valid/ready handshaking
- backpressure
- circular buffer pointers
- full and empty flags
- occupancy count
- directed and randomized verification

## Handshake Rule

A transfer occurs only on a rising clock edge when:

```systemverilog
valid && ready
