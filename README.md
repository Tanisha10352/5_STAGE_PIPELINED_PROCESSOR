# 🔧 5-Stage Pipelined Processor in Verilog

This project implements a **5-stage pipelined processor** in Verilog with **instruction-level parallelism**, **RAW hazard resolution using operand forwarding**, **branch handling with flush**, and support for **memory operations** like `LW` and `SW`. The pipeline supports a subset of MIPS-like instructions.


### ✅ Supported Instructions

| Type     | Mnemonic | Description                            |
|----------|----------|----------------------------------------|
| RR-ALU   | `ADD`    | Add contents of two registers          |
| RR-ALU   | `SUB`    | Subtract contents of two registers     |
| RR-ALU   | `AND`    | Bitwise AND                            |
| RR-ALU   | `OR`     | Bitwise OR                             |
| RR-ALU   | `SLT`    | Set if less than                       |
| RR-ALU   | `MUL`    | Multiply                                |
| RM-ALU   | `ADDI`   | Add immediate to register              |
| RM-ALU   | `SUBI`   | Subtract immediate                     |
| RM-ALU   | `SLTI`   | Set if less than (with immediate)      |
| Memory   | `LW`     | Load word from memory                  |
| Memory   | `SW`     | Store word to memory                   |
| Branch   | `BEQZ`   | Branch if equal to zero                |
| Branch   | `BNEQZ`  | Branch if not equal to zero            |
| Control  | `HLT`    | Halt processor                         |

---

## ⚙️ Pipeline Structure

The pipeline is composed of five stages:

1. **Instruction Fetch (IF)** – Reads instruction from memory.
2. **Instruction Decode (ID)** – Decodes instruction and reads registers.
3. **Execute (EX)** – Performs ALU operation, branch decision, effective address calc.
4. **Memory Access (MEM)** – Accesses data memory if needed.
5. **Write Back (WB)** – Writes result back to register file.

---

## ⚠️Data Hazard Handling

- **RAW (Read After Write)** hazard resolution using **Operand Forwarding**


 ---
## 🚦 Control Hazard Handling

- Branch instructions (`BEQZ`, `BNEQZ`) are resolved in the Execute stage.
- If a branch is taken:
  - PC is updated to branch target
  - The next instruction is **flushed** before entering Decode stage

---

## 🧪 verififcation

Carefully designed test program to verify every functionality.
The testbench initializes registers and memory and then runs a complete instruction sequence .

### 🧾 Program Flow

| PC  | Instruction                | Purpose                                     |
|-----|----------------------------|---------------------------------------------|
| 0   | `ADDI R1, R0, 10`         | R1 = 10                                     |
| 1   | `ADDI R2, R0, 5`          | R2 = 5                                      |
| 2   | `ADD R3, R1, R2`          | R3 = R1 + R2 = 15                           |
| 3   | `ADDI R4, R3, 1`          | R4 = R3 + 1 = 16                            |
| 5   | `SW R3, 20(R0)`           | MEM[20] = R3                                |
| 6   | `LW R1, 20(R0)`           | R1 = MEM[20] → R1 = 15                      |
| 7   | `ADDI R4, R0, 0`          | R4 = 0                                      |
| 8   | `BEQZ R4, 2`              | Skip next 2 instructions                    |
| 11  | `ADDI R2, R0, 111`        | R2 = 111                                    |
| 12  | `BNEQZ R2, 2`             | Skip next 2 instructions                    |
| 15  | `ADDI R3, R0, 123`        | R3 = 123                                    |
| 16  | `HLT`                     | Halt processor                              |

final register values matches the expected values

---

## 💡 Design Challenges & Solutions

### 🔍 Struggles

- Initial incorrect data due to RAW hazards
- Unintended execution of post-branch instructions
- Write-back not completing before HALT

### ✔ Solutions

- Used **Operand Forwarding** between EX and MEM stages
- Modified HALT logic to allow the last instruction to **write back**
- Introduced **FLUSH logic** on branches to clear wrong-path instructions

---
## 📘 Future Improvements

- Implement `LW → RR` stall logic for complete hazard support
- Add `JUMP`, `NOP`, and `JAL` instructions
- Add pipeline visualizer or instruction tracer
- Design assembler to convert MIPS-like assembly to binary



