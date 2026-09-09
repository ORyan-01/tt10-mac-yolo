import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ClockCycles

@cocotb.test()
async def test_mac_yolo(dut):
    dut._log.info("Iniciando prueba del coprocesador MAC para YOLO")

    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    async def run_mac(a, b, accumulate=0):
        # 1. Cargar A (load_b = 0)
        dut.ui_in.value = a & 0xFF
        dut.uio_in.value = (0 << 5) | (0 << 3) | (accumulate << 1) | 0
        await ClockCycles(dut.clk, 1)

        # 2. Cargar B y disparar (load_b = 1, valid_in = 1)
        dut.ui_in.value = b & 0xFF
        dut.uio_in.value = (1 << 5) | (0 << 3) | (accumulate << 1) | 1
        await ClockCycles(dut.clk, 1)

        dut.uio_in.value = (1 << 5) | (0 << 3) | (accumulate << 1) | 0
        await ClockCycles(dut.clk, 1)

        # 3. Leer los 4 bytes del resultado de 32 bits
        result_bytes = []
        for b_sel in range(4):
            dut.uio_in.value = (1 << 5) | (b_sel << 3) | (accumulate << 1) | 0
            await FallingEdge(dut.clk)
            result_bytes.append(int(dut.uo_out.value))

        full_val = 0
        for i, val in enumerate(result_bytes):
            full_val |= (val << (8 * i))
        
        if full_val & 0x80000000:
            full_val -= 0x100000000

        return full_val

    # Prueba de multiplicación simple (5 * 6 = 30)
    res = await run_mac(5, 6, accumulate=0)
    dut._log.info(f"Resultado 5 * 6 = {res}")
    assert res == 30, f"Se esperaba 30, se obtuvo {res}"

    # Prueba de acumulación (30 + 10 * 4 = 70)
    res_acc = await run_mac(10, 4, accumulate=1)
    dut._log.info(f"Resultado acumulado = {res_acc}")
    assert res_acc == 70, f"Se esperaba 70, se obtuvo {res_acc}"

    dut._log.info("¡Pruebas superadas con éxito!")
