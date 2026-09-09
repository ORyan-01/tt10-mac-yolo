---
title: OptiMac
author: Joaquín O'Ryan
discord: oryan01.
---

## How it works
Este diseño es un acelerador de hardware Multiply-Accumulate (MAC) de un ciclo optimizado para la inferencia de modelos pequeños de visión por computadora. Toma dos vectores de entrada de 8 bits con signo (`ui_in` y `uio_in`), los multiplica y acumula el resultado continuamente en un registro interno de 32 bits.

## How to test
Aplica un ciclo de reset llevando `rst_n` a 0. Luego, en cada flanco positivo del reloj, entrega los operandos A y B. El registro interno acumulará los resultados y los emitirá a través de `uo_out`. La salida está equipada con una lógica combinacional que satura el resultado al rango de enteros de 8 bits con signo ([-128, 127]) para evitar desbordamientos desapercibidos en la lectura externa.
