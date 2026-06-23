TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = $(PWD)/../rtl/axis_sync_fifo_core.sv

TOPLEVEL = axis_sync_fifo_core
MODULE = test_axis_sync_fifo

EXTRA_ARGS += --trace --trace-structs
EXTRA_ARGS += -GDATA_W=32 -GDEPTH=8

include $(shell cocotb-config --makefiles)/Makefile.sim
