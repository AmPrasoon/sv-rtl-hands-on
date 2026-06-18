# cocotb + Verilator Counter Smoke Test

This is a small first experiment to check a cocotb + Verilator simulation flow on WSL/Linux.

## Design

The RTL is a simple parameterized synchronous counter with:

- active-low reset
- enable input
- registered count output

## Verification

The cocotb test checks:

- reset behavior
- counting when enable is high
- hold behavior when enable is low

The test also uses a safe timing pattern:

- drive inputs on or around the falling edge
- check registered outputs after `RisingEdge` followed by `ReadOnly`

This avoids simple race-condition issues between Python test code and RTL non-blocking assignments.
