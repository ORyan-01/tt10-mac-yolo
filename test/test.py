import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_mac_int8(dut):
    dut._log.info("Iniciando test de verificacion MAC INT8...")

    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Prueba 1: 5 * 10 = 50")
    dut.ui_in.value = 5
    dut.uio_in.value = 10
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.signed_integer == 50

    dut._log.info("Prueba 2: Acumulacion 50 + (-3 * 4) = 38")
    dut.ui_in.value = -3
    dut.uio_in.value = 4
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.signed_integer == 38

    dut._log.info("Prueba 3: Saturacion (+127 max)")
    dut.ui_in.value = 100
    dut.uio_in.value = 2
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value.signed_integer == 127
