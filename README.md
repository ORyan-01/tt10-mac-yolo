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

## 🛠️ Inputs and Outputs (Tiny Tapeout Wrapper)
* `ui_in` [7:0]: Operand A (`a_in`, signed 8-bit input for weights/activations).
* `uio_in` [7:0]: Operand B (`b_in`, signed 8-bit input for weights/activations).
* `uo_out` [7:0]: Saturated 8-bit output (`sat_out`, derived from the 32-bit accumulator `mac_result`).
* `clk`: System clock.
* `rst_n`: Active-low asynchronous reset.

*(Note: Designed by Joaquín O'Ryan)*
