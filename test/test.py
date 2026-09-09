import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_mac(dut):
    dut._log.info("Iniciando prueba del MAC INT8")

    # 1. Configurar y arrancar el reloj a 50MHz
    clock = Clock(dut.clk, 20, units="ns") 
    cocotb.start_soon(clock.start())

    # 2. Inicializar entradas (Reset)
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0 # Activar reset
    
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1 # Desactivar reset
    await ClockCycles(dut.clk, 2)

    # 3. Prueba 1: Multiplicacion simple (3 * 4)
    dut._log.info("Prueba 1: 3 * 4")
    dut.ui_in.value = 3
    dut.uio_in.value = 4
    
    # Esperamos 1 ciclo de reloj porque nuestro Verilog es secuencial (usa Flip-Flops)
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk) # Leemos a la bajada para asegurar que el dato está listo
    
    assert int(dut.uo_out.value) == 12, f"Error: Se esperaba 12, se obtuvo {int(dut.uo_out.value)}"

    # 4. Prueba 2: Multiplicacion mas grande (10 * 5)
    dut._log.info("Prueba 2: 10 * 5")
    dut.ui_in.value = 10
    dut.uio_in.value = 5
    
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk)
    
    assert int(dut.uo_out.value) == 50, f"Error: Se esperaba 50, se obtuvo {int(dut.uo_out.value)}"

    dut._log.info("¡Todas las pruebas pasaron exitosamente!")
