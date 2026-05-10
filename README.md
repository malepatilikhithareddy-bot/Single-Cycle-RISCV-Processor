# RISC-V Processor Design using Verilog

## Overview
This project implements a basic RISC-V processor using Verilog HDL. The processor is designed using modular architecture and includes essential components such as the ALU, Control Unit, Register File, Instruction Memory, Data Memory, Immediate Generator, and Branch Control Unit.

The project is verified through simulation using a Verilog testbench and is targeted for FPGA implementation using the Basys3 development board.

---

## Features
- Modular RISC-V processor architecture
- ALU for arithmetic and logical operations
- Control Unit for instruction decoding
- Register File implementation
- Instruction and Data Memory modules
- Immediate value generation
- Branch control logic
- FPGA compatible design
- Functional simulation support

---

## Technologies Used
- Verilog HDL
- Vivado
- FPGA Design
- Digital System Design

---

## Project Structure

```text
RISCV-Processor-Verilog/
│
├── src/
│   ├── alu.v
│   ├── alu_control.v
│   ├── branch_control.v
│   ├── control_unit.v
│   ├── data_mem.v
│   ├── imm_gen.v
│   ├── instr_mem.v
│   ├── register_file.v
│   ├── riscv_core.v
│   ├── seg7.v
│   └── top.v
│
├── testbench/
│   └── tb_top.v
│
├── constraints/
│   └── basys3.xdc
│
├── images/
│   ├── block_diagram.png
│   ├── rtl_schematic.png
│   └── waveform.png
│
├── docs/
│   ├── project_report.pdf
│   └── presentation.pdf
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Modules Description

### ALU (`alu.v`)
Performs arithmetic and logical operations required by the processor.

### ALU Control (`alu_control.v`)
Generates ALU operation control signals based on instruction type.

### Control Unit (`control_unit.v`)
Decodes instructions and generates processor control signals.

### Register File (`register_file.v`)
Stores processor registers and handles read/write operations.

### Instruction Memory (`instr_mem.v`)
Stores program instructions executed by the processor.

### Data Memory (`data_mem.v`)
Handles data storage operations during execution.

### Immediate Generator (`imm_gen.v`)
Extracts and generates immediate values from instructions.

### Branch Control (`branch_control.v`)
Controls branching decisions during instruction execution.

### RISC-V Core (`riscv_core.v`)
Main processor core integrating all modules.

### Top Module (`top.v`)
Top-level integration module for FPGA implementation.

### Seven Segment Display (`seg7.v`)
Drives seven-segment display outputs on the FPGA board.

### Testbench (`tb_top.v`)
Used for functional verification and simulation of the processor.

---

## Simulation
The processor functionality is verified using the `tb_top.v` testbench in Vivado simulator.

---

## FPGA Implementation
The project is targeted for implementation on the Basys3 FPGA development board using the provided constraint file.

---

## Applications
- Computer Architecture Learning
- FPGA-based Processor Design
- Embedded Systems
- Digital System Design Education
- RISC-V Architecture Study

---

## How to Run the Project

### Using Vivado
1. Open Vivado
2. Create a new project
3. Add all Verilog source files from the `src/` folder
4. Add `tb_top.v` as simulation source
5. Add `basys3.xdc` constraints file
6. Run behavioral simulation
7. Run synthesis and implementation for FPGA deployment

---

## Future Improvements
- Pipeline implementation
- Hazard detection and forwarding
- Cache memory integration
- UART communication support
- Extended RISC-V instruction support

---

## Author
M. Likhitha Reddy

---

## License
This project is licensed under the MIT License.
