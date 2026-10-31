# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):

    dut._log.info("Starting TCPU-16 test")

    # Start clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    dut._log.info("Reset")
    await ClockCycles(dut.clk, 10)

    # Release reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    dut._log.info("Test project behavior")

    # Check that output pins are configured as inputs
    assert int(dut.uio_oe.value) == 0

    dut._log.info("TCPU-16 interface test passed")
