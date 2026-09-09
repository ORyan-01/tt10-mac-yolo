# INT8 MAC Accelerator for YOLO Edge Inference

## 📌 Overview
This repository contains the RTL implementation of an 8-bit Multiply-Accumulate (MAC) unit designed as a hardware coprocessor for quantized neural networks, specifically targeting YOLO INT8 inference models. The design has been fully optimized and has successfully passed the OpenLane physical design flow, proving its readiness for ASIC fabrication through open-source shuttles like Tiny Tapeout.

## ⚙️ Architecture
In Edge AI applications, hardware offloading is critical. This module relieves the main processor from heavy tensor math by executing convolutions in dedicated silicon.
* **Multiplier:** 8-bit x 8-bit (Signed).
* **Accumulator:** 32-bit register to prevent overflow during deep convolutional layer operations.
* **Precision:** INT8 (Industry standard for Edge AI, balancing area efficiency and inference accuracy).

## 🔬 Verification & Physical Flow
* **RTL Verification:** Exhaustive testbenches passing all corner cases (saturation, negative values, zero-multiplications).
* **GDSII Ready:** The design successfully passes the physical flow, meeting all timing and area constraints for standard grid integrations.

## 🛠️ Inputs and Outputs
* `ui_in` [7:0]: 8-bit Input A (Weights / Activations)
* `uio_in` [7:0]: 8-bit Input B (Weights / Activations)
* `uo_out` [7:0]: Output (Lower 8 bits of Accumulator or multiplexed output)
* `clk`: Clock signal
* `rst_n`: Active-low reset

*(Note: Designed by Joaquín O'Ryan)*
