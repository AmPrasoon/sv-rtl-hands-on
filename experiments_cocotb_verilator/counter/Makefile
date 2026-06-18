TOPLEVEL_LANG = verilog
SIM = verilator

VERILOG_SOURCES = $(PWD)/rtl/counter.sv

TOPLEVEL = counter
MODULE = tb.test_counter

EXTRA_ARGS += --trace --trace-structs

include $(shell cocotb-config --makefiles)/Makefile.sim
