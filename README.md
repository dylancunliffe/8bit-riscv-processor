# 8-Bit RISC Processor — FPGA Implementation

A simple **8-bit RISC CPU** designed and implemented in **SystemVerilog** on the **Intel MAX10 FPGA**.  
This project integrates an **Arithmetic Logic Unit (ALU)**, **dual-ported register file**, and **datapath control** into a functional CPU capable of executing **8 custom machine instructions**.

---

## Repository Contents

| File | Description |
|------|--------------|
| **`alu.sv`** | Implements the 8-bit Arithmetic Logic Unit supporting ADD, SUB, MUL, and AND operations with condition flags (N, Z, C, BR, VP, VN). |
| **`register.sv`** | Defines the dual-ported register file containing four 8-bit general-purpose registers with simultaneous read/write access. |
| **`cpu.sv`** | Top-level SystemVerilog module that integrates the ALU, register file, memory, immediate mux, and output logic into a working CPU datapath. |
| **`cpu-project.qpf`** | Quartus project file used for synthesis and FPGA compilation. |
| **`cpu.sof`** | Compiled FPGA configuration bitstream for the Intel MAX10 development board. |

---

## Features

- 8-bit RISC-style CPU architecture  
- 4 general-purpose registers (R0–R3)  
- ALU supporting **ADD**, **SUB**, **MUL**, **AND**  
- Signed & unsigned condition flags generated automatically  
- Immediate +1 / −1 operations  
- Load/store operations to internal memory  
- Instruction execution controlled entirely by **FPGA switches**

---

## Instruction Set Overview

This CPU supports **8 custom hardware-coded instructions**, created by configuring control signals via the board switches.  
Each instruction is essentially a specific combination of mux selects, register indices, and ALU operations.

### **Instruction Summary**

| Instruction | Description |
|------------|-------------|
| **ADD rA, rB** | Performs `rA ← rA + rB` using ALU operation `00`. |
| **SUB rA, rB** | Performs `rA ← rA - rB` using ALU operation `01`. |
| **MUL rA, rB** | Performs `rA ← rA * rB` using ALU operation `10`. |
| **AND rA, rB** | Performs `rA ← rA & rB` using ALU operation `11`. |
| **MOV rA, rB** | Copies `rA ← rB` using result select `10`. |
| **MOV rA, Imm (+1)** | Loads +1 into register A (`Imm = 0`). |
| **MOV rA, Imm (–1)** | Loads −1 (0xFF) into register A (`Imm = 1`). |
| **LOAD rA, [rB]** | Loads from memory at address `rB` into `rA`. |
| **STORE rA → [rB]** | Stores `rA` into memory at address `rB`. |

These instructions are created directly through hardware control — **no machine code encoding**, just switch-level datapath control.

---

## Usage

1. Open `cpu-project.qpf` in **Intel Quartus Prime**.  
2. Compile and upload to the **Intel MAX10 FPGA**.  
3. Configure the datapath via `SW[9:0]`:

   - `SW[9]` → Write Enable  
   - `SW[8:7]` → Register A Select  
   - `SW[6:5]` → Register B Select  
   - `SW[4:3]` → ALU Operation (`00=ADD`, `01=SUB`, `10=MUL`, `11=AND`)  
   - `SW[2]` → Immediate Select (`0=+1`, `1=−1`)  
   - `SW[1:0]` → Result Select (`00=Mem`, `01=ALU`, `10=B`, `11=Imm`)  

4. Step through your program clock cycles using the **KEY buttons**.

---

## Example Programs

- Increment registers  
- Compute factorial  
- Generate Fibonacci sequence  
- Compute GCD using subtraction and condition flags  

---
