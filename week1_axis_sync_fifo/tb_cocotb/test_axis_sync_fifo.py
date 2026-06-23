import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.s_tdata.value = 0
    dut.s_tvalid.value = 0
    dut.m_tready.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    await RisingEdge(dut.clk)
    await ReadOnly()


async def axis_write(dut, data):
    await FallingEdge(dut.clk)
    dut.s_tdata.value = data
    dut.s_tvalid.value = 1

    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()

        if int(dut.s_tready.value) == 1:
            break

    await FallingEdge(dut.clk)
    dut.s_tvalid.value = 0
    dut.s_tdata.value = 0


async def axis_read(dut):
    await FallingEdge(dut.clk)
    dut.m_tready.value = 1

    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()

        if int(dut.m_tvalid.value) == 1:
            data = int(dut.m_tdata.value)
            break

    await FallingEdge(dut.clk)
    dut.m_tready.value = 0

    return data


@cocotb.test()
async def basic_write_read_test(dut):
    """Write three words and read them back in order."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    assert int(dut.empty.value) == 1
    assert int(dut.full.value) == 0
    assert int(dut.count.value) == 0

    await axis_write(dut, 0x11)
    await axis_write(dut, 0x22)
    await axis_write(dut, 0x33)

    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.count.value) == 3

    r0 = await axis_read(dut)
    r1 = await axis_read(dut)
    r2 = await axis_read(dut)

    assert r0 == 0x11, f"Expected 0x11, got {r0:#x}"
    assert r1 == 0x22, f"Expected 0x22, got {r1:#x}"
    assert r2 == 0x33, f"Expected 0x33, got {r2:#x}"

    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.empty.value) == 1
    assert int(dut.count.value) == 0


@cocotb.test()
async def fill_fifo_test(dut):
    """Fill FIFO to DEPTH and check full flag/backpressure."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    depth = 8

    for i in range(depth):
        await axis_write(dut, i + 1)

    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.full.value) == 1
    assert int(dut.empty.value) == 0
    assert int(dut.count.value) == depth
    assert int(dut.s_tready.value) == 0

    for i in range(depth):
        data = await axis_read(dut)
        assert data == i + 1, f"Expected {i + 1}, got {data}"

    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.empty.value) == 1
    assert int(dut.full.value) == 0
    assert int(dut.count.value) == 0


@cocotb.test()
async def randomized_write_read_test(dut):
    """Random producer/consumer stalls with scoreboard checking."""

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset_dut(dut)

    random.seed(1)

    num_words = 50
    input_data = [random.randint(0, 255) for _ in range(num_words)]
    expected_queue = []
    received_data = []

    write_idx = 0

    for _cycle in range(1000):
        await FallingEdge(dut.clk)

        if write_idx < num_words and random.choice([0, 1]):
            dut.s_tvalid.value = 1
            dut.s_tdata.value = input_data[write_idx]
        else:
            dut.s_tvalid.value = 0
            dut.s_tdata.value = 0

        dut.m_tready.value = random.choice([0, 1])

        await RisingEdge(dut.clk)
        await ReadOnly()

        s_fire = int(dut.s_tvalid.value) and int(dut.s_tready.value)
        m_fire = int(dut.m_tvalid.value) and int(dut.m_tready.value)

        if s_fire:
            expected_queue.append(input_data[write_idx])
            write_idx += 1

        if m_fire:
            observed = int(dut.m_tdata.value)
            expected = expected_queue.pop(0)
            received_data.append(observed)

            assert observed == expected, (
                f"Data mismatch: expected {expected}, got {observed}"
            )

        if len(received_data) == num_words:
            break

    assert received_data == input_data, "Received sequence does not match input sequence"
