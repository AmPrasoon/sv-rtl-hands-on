#!/usr/bin/env bash

set -e

rm -rf obj_dir logs
mkdir -p logs

verilator \
  --binary \
  --timing \
  --trace \
  --top-module tb_axis_sync_fifo_if_wrap \
  ../rtl/axis_stream_if.sv \
  ../rtl/axis_sync_fifo_core.sv \
  ../rtl/axis_sync_fifo_if_wrap.sv \
  ../tb_sv/tb_axis_sync_fifo_if_wrap.sv

./obj_dir/Vtb_axis_sync_fifo_if_wrap
