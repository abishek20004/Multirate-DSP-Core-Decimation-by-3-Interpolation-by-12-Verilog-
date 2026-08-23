# Multirate-DSP-Core-Decimation-by-3-Interpolation-by-12-Verilog-

Technical assessment submission for ApexPlus Technologies

# 1. Project Overview

This project implements and verifies a multirate DSP signal-processing chain using Xilinx FIR Compiler IP cores and Verilog HDL.

The system performs:

1. Input signal generation in Q1.15 fixed-point format
2. Decimation by 3
3. Interpolation by 12
4. Fixed-point format conversion at the output
5. Simulation using Vivado
6. Frequency-domain verification using MATLAB FFT analysis

## System Architecture

```text
                Input Signal
                 120 MHz
                    │
                    ▼
            ┌────────────────┐
            │ FIR Decimator  │
            │       /3       │
            └───────┬────────┘
                    │
                  40 MHz
                    │
                    ▼
            ┌────────────────┐
            │ FIR Interpolator│
            │      ×12        │
            └───────┬────────┘
                    │
                 480 MHz
                    │
                    ▼
             Final Output
