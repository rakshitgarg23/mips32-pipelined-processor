# 5-Stage Pipelined RISC Processor

## Project Overview
This project is a clean, simple, and educational 5-stage pipelined RISC processor written in Verilog HDL. It is inspired by the MIPS32 architecture and is designed to demonstrate the fundamentals of pipelined instruction execution without the complexity of advanced features like forwarding or branch prediction. 

It is an ideal baseline project for computer architecture students, focusing on readability, modularity, and core concepts that are easy to explain during technical interviews.

## Features
- **5-Stage Pipeline**: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).
- **Supported Instruction Set**: 
  - Arithmetic: `ADD`, `SUB`, `ADDI`
  - Logical: `AND`, `OR`
  - Memory: `LW`, `SW`
  - Control Flow: `BEQ` (Note: As branch prediction and forwarding are omitted for simplicity, branch instructions execute with a 3-cycle branch delay).
- **Hazard Handling**: Data hazards are managed in software via manual insertion of NOPs (`ADD r0, r0, r0`) to keep the hardware design simple and intuitive.
- **Modular RTL**: Clean separation of pipeline registers and processor components.

## Block Diagram
```text
      +----+      +----+      +----+      +----+      +----+
PC -> | IF | ---> | ID | ---> | EX | ---> | MEM| ---> | WB |
      +----+      +----+      +----+      +----+      +----+
        |           |           |           |           |
      IMEM       RegFile       ALU        DMEM    Write to RegFile
```

## Pipeline Stage Explanation
1. **Instruction Fetch (IF)**: Fetches the instruction from Instruction Memory using the Program Counter (PC). Updates PC to PC + 4.
2. **Instruction Decode (ID)**: Decodes the instruction, extracts operands from the Register File, and generates control signals via the Control Unit.
3. **Execute (EX)**: Performs arithmetic or logical operations using the ALU. Computes branch target addresses (if branch instructions are supported).
4. **Memory Access (MEM)**: Reads from or writes to the Data Memory for `LW` or `SW` instructions.
5. **Write Back (WB)**: Writes the ALU result or memory read data back into the Register File.

## Directory Structure
```
pipeline-risc-processor/
├── rtl/
│   ├── program_counter.v
│   ├── instruction_memory.v
│   ├── register_file.v
│   ├── alu.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── pipeline_registers.v
│   └── top_processor.v
├── tb/
│   └── tb_top_processor.v
├── README.md
├── run_sim.bat
└── .gitignore
```

## Module Description
- `top_processor.v`: Top-level module wiring all stages and pipeline registers.
- `pipeline_registers.v`: Contains IF/ID, ID/EX, EX/MEM, and MEM/WB registers.
- `control_unit.v`: Generates execution control signals based on opcodes.
- `alu.v`: Performs computational tasks (add, sub, and, or).
- `register_file.v`: 32x32-bit register file (r0 is always 0).
- `instruction_memory.v` / `data_memory.v`: Simple memory models for instructions and data.

## Simulation Instructions
Prerequisites: **Icarus Verilog** and **GTKWave**.

1. Open a terminal or command prompt.
2. Navigate to the project directory.
3. Run the simulation script:
   ```bash
   run_sim.bat
   ```
4. GTKWave will open automatically, allowing you to view pipeline progression and signal waveforms.

## Expected Waveform
When you open GTKWave, inspect `tb_top_processor.vcd`. You will see:
- `clk` toggling and `pc` incrementing by 4.
- `instr` passing through pipeline stages.
- `r1`, `r2`, and `r3` in the `register_file` updating with correct arithmetic results after WB stages.
