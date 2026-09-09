import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge

@cocotb.test()
async def test_mac_int8(dut):
    dut._log.info("Iniciando test de verificacion MAC INT8 (con sincronizacion de flancos)...")

    # Reloj a 10 MHz
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Estado inicial / Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Prueba 1: Multiplicacion simple (5 * 10 = 50)
    dut.ui_in.value = 5
    dut.uio_in.value = 10
    await ClockCycles(dut.clk, 1)
    # Esperamos medio ciclo extra para que la logica de saturacion propague el resultado
    await FallingEdge(dut.clk) 
    assert dut.uo_out.value.signed_integer == 50, f"Error: Esperado 50, obtenido {dut.uo_out.value.signed_integer}"

    # Prueba 2: Acumulacion con signo (50 + (-3 * 4) = 38)
    dut.ui_in.value = -3
    dut.uio_in.value = 4
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk)
    assert dut.uo_out.value.signed_integer == 38, f"Error: Esperado 38, obtenido {dut.uo_out.value.signed_integer}"

    # Prueba 3: Verificacion de saturacion (+127 max)
    dut.ui_in.value = 100
    dut.uio_in.value = 2
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk)
    assert dut.uo_out.value.signed_integer == 127, f"Error: Esperado 127, obtenido {dut.uo_out.value.signed_integer}"
