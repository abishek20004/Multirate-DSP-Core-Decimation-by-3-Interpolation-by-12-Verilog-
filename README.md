# Multirate DSP Core – Decimation by 3 + Interpolation by 12 (Verilog)

**Technical assessment submission for ApexPlus Technologies**

This repository implements and verifies a complete multirate DSP signal-processing chain using **Xilinx FIR Compiler IP cores** and custom Verilog HDL.  
The design performs **decimation by 3** followed by **interpolation by 12**, converting a 120 MHz input stream into a 480 MHz output stream while preserving signal integrity in fixed-point arithmetic.

---

## System Overview

| Stage              | Rate Change | Sampling Frequency | Data Format          |
|--------------------|-------------|--------------------|----------------------|
| Input              | –           | 120 MHz            | 16-bit Q1.15        |
| FIR Decimator      | ÷ 3         | 40 MHz             | 24-bit intermediate |
| Format Conversion  | –           | 40 MHz             | 16-bit Q1.15        |
| FIR Interpolator   | × 12        | 480 MHz            | 64-bit packed (4×16-bit) |
| Final Output       | –           | 480 MHz            | 4 × 16-bit Q1.15    |

**Overall rate conversion factor**: 12 / 3 = **4×**

---

### Architecture Diagram

```text
                Input Signal
                 120 MHz
                (Q1.15)
                    │
                    ▼
            ┌────────────────┐
            │  FIR Decimator │  ÷ 3
            │   (51-tap LPF) │
            └───────┬────────┘
                    │
                  40 MHz
                    │
                    ▼
            ┌────────────────┐
            │ Format Convert │  24-bit → 16-bit Q1.15
            └───────┬────────┘
                    │
                    ▼
            ┌────────────────┐
            │ FIR Interpolator│  × 12
            │  (51-tap LPF)  │
            └───────┬────────┘
                    │
                 480 MHz
              (4× parallel samples)
                    │
                    ▼
              Final Output
           (packed 64-bit Q1.15)
```
---

## Key Features

1. Xilinx FIR Compiler polyphase decimator (factor 3) and interpolator (factor 12)
2. AXI4-Stream interfaces throughout
3. Fixed-point arithmetic with careful Q-format management
4. 51-tap low-pass FIR filters (Hamming window design)
5. Complete testbench with file-based stimulus and result capture
6. MATLAB-based frequency-domain verification (FFT analysis)
7. Simulation results and plots included

---

## Filter Specifications

**Decimator (dec_3)**
![Decimator (dec_3)](IP_configuratio/dec_3.png)

**Interpolator (interp_12)**
![Interpolator (interp_12)](IP_configuratio/interp_12.png)

---

## Fixed-Point Handling

1. Input → 16-bit Q1.15
2. Decimator output → 24-bit (Q2.15 style, 15 fractional bits preserved)
3. Truncation / selection of lower 16 bits → Q1.15 for interpolator input
4. Interpolator output → 16-bit samples with extra fractional bits
5. Arithmetic right-shift by 3 bits + scaling by interpolation factor (×12) → final Q1.15 samples
6. Four consecutive samples packed into a 64-bit word

**Note:** The scaling by 12 after the right-shift compensates for the interpolation gain and fractional-bit adjustment according to the IP configuration used.

---

## Verification Results

1. Input signal: 1 MHz sine wave sampled at 120 MHz (Q1.15)
2. After decimation (40 MHz) and interpolation (480 MHz), the 1 MHz tone is correctly preserved
3. MATLAB FFT plots confirm spectral integrity at each stage
4. Full simulation recording is available in simulation/simulation_recordings.mp4

---

## Design Notes & Observations

1. Both filters are 51-tap designs for good stop-band attenuation while remaining practical for FPGA implementation.
2. The interpolator produces 4 parallel samples per clock cycle (64-bit output), matching the ×12 rate increase relative to the intermediate 40 MHz clock domain when running on a common high-speed clock.
3. Careful Q-format management is performed between the two IPs to avoid overflow and maintain fractional precision.
4. The design uses a single common clock (aclk) for both FIR cores (typical for FIR Compiler multi-rate configurations when the clock is fast enough).

---

## 👨‍💻 Abishek S
- **Email:** xia2020.abisheks@gmail.com
- **LinkedIn:** [linkedin.com/in/abishek-s-848564258](https://www.linkedin.com/in/abishek-s-848564258)

