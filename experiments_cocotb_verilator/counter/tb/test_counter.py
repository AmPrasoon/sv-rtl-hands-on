import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly


@cocotb.test()
async def counter_basic_test(dut):
    """Basic reset and enable test for a simple counter."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # Initial values
    dut.rst_n.value = 0
    dut.en.value = 0

    # Hold reset for a few cycles
    for _ in range(5):
        await RisingEdge(dut.clk)

    # Release reset away from the active clock edge
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.en.value = 0

    # Check counter after reset release
    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.count.value) == 0, (
        f"After reset, expected count=0, got {int(dut.count.value)}"
    )

    # Drive enable on falling edge, not during ReadOnly phase
    await FallingEdge(dut.clk)
    dut.en.value = 1

    # Check counting behavior
    for expected in range(1, 6):
        await RisingEdge(dut.clk)
        await ReadOnly()

        observed = int(dut.count.value)
        assert observed == expected, (
            f"Expected count={expected}, got {observed}"
        )

    # Disable on falling edge
    await FallingEdge(dut.clk)
    dut.en.value = 0

    # Capture hold value
    await RisingEdge(dut.clk)
    await ReadOnly()
    hold_value = int(dut.count.value)

    # Counter should remain unchanged while disabled
    for _ in range(3):
        await RisingEdge(dut.clk)
        await ReadOnly()

        observed = int(dut.count.value)
        assert observed == hold_value, (
            f"Counter changed while disabled: expected {hold_value}, got {observed}"
        )
