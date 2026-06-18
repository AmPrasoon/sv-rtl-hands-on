# FPGA RTL Lab

This repository contains small, self-contained SystemVerilog RTL design exercises focused on FPGA-based streaming datapaths, buffering, clock-domain crossing, verification, and implementation analysis.

## Motivation

The goal of this repository is to maintain a clean collection of practical RTL design examples that can be simulated, reviewed, extended, and eventually mapped to FPGA hardware.

The examples are intentionally compact and modular. Each exercise focuses on a specific hardware-design concept such as valid/ready handshaking, FIFO control, clock-domain crossing, streaming computation, timing constraints, or on-chip debug.

I am also using this repository to gradually become more comfortable with modern open-source RTL verification flows such as cocotb and Verilator. Since these tools have their own learning curve, the plan is to start with simple testbenches and then slowly extend the examples with Python-based verification, randomized testing, and automated checks.

## Topics

- SystemVerilog RTL design
- AXI4-Stream-style valid/ready interfaces
- Synchronous FIFO design
- Asynchronous FIFO and CDC handling
- Streaming image-processing datapaths
- Backpressure-aware pipeline control
- Testbench-based functional verification
- cocotb-based Python verification experiments
- Verilator-based simulation experiments
- Vivado constraints and timing analysis
- FPGA debug using ZCU104

## Project Structure

| Folder | Topic | Description |
|---|---|---|
| `week1_axis_sync_fifo/` | AXI-style synchronous FIFO | Parameterized FIFO with valid/ready handshake and basic verification |
| `week2_async_fifo_cdc/` | Asynchronous FIFO and CDC | Gray-coded pointer FIFO and synchronizer-based CDC handling |
| `week3_streaming_image_filter/` | Streaming image filter | Pipelined pixel-processing datapath with backpressure support |
| `week4_vivado_zcu104/` | FPGA implementation | Vivado constraints, timing analysis, CDC checks, and ZCU104 debug |
| `experiments_cocotb_verilator/` | Open-source verification experiments | Small experiments using cocotb and Verilator as I build familiarity with these flows |

## Tools

- SystemVerilog
- QuestaSim / ModelSim
- Vivado
- ZCU104 FPGA board
- cocotb
- Verilator
- Python
- Ubuntu / WSL development environment

## Repository Policy

This repository contains only self-written educational and experimental RTL examples. It does not contain confidential research, employer, laboratory, or third-party proprietary code.

Generated tool outputs, simulation databases, bitstreams, and large implementation artifacts are intentionally excluded from version control.
