# RTL Interview Prep FPGA

Hands-on SystemVerilog RTL design preparation focused on FPGA/RTL engineering interviews.

## Motivation

This repository contains small, self-contained RTL design exercises for practicing:

- SystemVerilog RTL coding
- AXI4-Stream valid/ready handshakes
- FIFO design
- clock-domain crossing
- streaming image-processing pipelines
- Vivado constraints and timing analysis
- FPGA debug using ZCU104

## Weekly Plan

| Week | Topic | Main Deliverable |
|---|---|---|
| Week 1 | AXI4-Stream synchronous FIFO | Parameterized FIFO + SystemVerilog testbench |
| Week 2 | Asynchronous FIFO and CDC | Gray-code pointer FIFO + CDC checks |
| Week 3 | Streaming image filter | 1D/2D filter pipeline with backpressure |
| Week 4 | Vivado/ZCU104 implementation | Constraints, timing reports, ILA debug |

## Tools

- SystemVerilog
- QuestaSim / ModelSim
- Vivado
- ZCU104 FPGA board
- Ubuntu / WSL development environment

## Repository Policy

This repository contains only self-written interview-preparation examples. It does not contain confidential research, employer, or laboratory code.
