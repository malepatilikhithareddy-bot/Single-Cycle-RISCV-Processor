# 32-bit RISC-V Processor with Keypad & 7-Segment Display
## Basys3 FPGA Implementation

---

## How It Works (Exact Flow)

```
USER PRESSES DIGIT(S)          USER PRESSES *             PROCESSOR EXECUTES
─────────────────────          ──────────────             ──────────────────
  Key [0][5] pressed     →     * pressed           →     Fetch instr[5]
  Display shows "0005"         DP stops blinking         Decode instruction
  DP blinks (entry mode)       Processor jumps to        Execute in ALU
                               instruction addr 5        Memory access
                               (PC = 5 × 4 = 0x14)      Write-back to reg
                                                         Result → 7-seg
```

---

## Keypad Layout & Key Functions

```
┌─────┬─────┬─────┬─────┐
│  1  │  2  │  3  │  A  │   ← Hex digits
├─────┼─────┼─────┼─────┤
│  4  │  5  │  6  │  B  │   ← Hex digits
├─────┼─────┼─────┼─────┤
│  7  │  8  │  9  │  C  │   ← Hex digits
├─────┼─────┼─────┼─────┤
│  *  │  0  │  #  │  D  │
└─────┴─────┴─────┴─────┘
  ↑               ↑
CONFIRM(ENTER)   CANCEL
(executes)       (clears)
```

**Step by step to run instruction 5 (OR x6,x1,x2):**
1. Press `[0]` → display shows `0000`, DP blinks
2. Press `[5]` → display shows `0005`, DP blinks
3. Press `[*]` → processor jumps to PC=0x14, executes OR, result=7 shown

**To run instruction 10 (LUI x11, 0x12345):**
1. Press `[1]` then `[0]` → display shows `0010`
2. Press `[*]` → result = `0x2345` shown (lower 16 bits)
3. Flip SW[2] up to see upper 16 bits `0x1234`

---

## Pre-loaded Instruction Program

| Index | Hex Address | Instruction          | Expected Result |
|-------|-------------|----------------------|-----------------|
| 1     | 0x04        | ADDI x2, x0, 3      | x2 = 3          |
| 2     | 0x08        | ADD  x3, x1, x2     | x3 = 8          |
| 3     | 0x0C        | SUB  x4, x3, x1     | x4 = 3          |
| 4     | 0x10        | AND  x5, x1, x2     | x5 = 1          |
| 5     | 0x14        | OR   x6, x1, x2     | x6 = 7          |
| 6     | 0x18        | XOR  x7, x1, x2     | x7 = 6          |
| 7     | 0x1C        | SLL  x8, x1, x2     | x8 = 40 (0x28)  |
| 8     | 0x20        | SRL  x9, x8, x2     | x9 = 5          |
| 9     | 0x24        | SLT  x10, x2, x1   | x10 = 1         |
| 10    | 0x28        | LUI  x11, 0x12345   | x11 = 0x12345000|
| 11    | 0x2C        | ADDI x12, x0, 15   | x12 = 15 (0xF)  |
| 12    | 0x30        | SW   x12, 0(x0)    | mem[0] = 15     |
| 13    | 0x34        | LW   x13, 0(x0)    | x13 = 15        |
| 14    | 0x38        | ADDI x14, x0, 99   | x14 = 99 (0x63) |
| 15    | 0x3C        | JAL  x0, 0 (HALT)  | LED[15] lights  |

> **Note:** Instructions build on each other. To see correct results,
> run them in order 0→1→2→3... because later instructions use register
> values set by earlier ones.

---

## Switch Controls

| Switch | Function |
|--------|----------|
| SW[0]  | Display mode bit 0 |
| SW[1]  | Display mode bit 1 |
| SW[1:0]=00 | Show **ALU/writeback result** (default) |
| SW[1:0]=01 | Show **Program Counter** |
| SW[1:0]=10 | Show **destination register number** (rd) |
| SW[1:0]=11 | Show **memory read data** (for LW) |
| SW[2]=0 | Display **lower 16 bits** |
| SW[2]=1 | Display **upper 16 bits** |

---

## LED Indicators

| LED | Meaning |
|-----|---------|
| LED[15] | **HALT** - processor reached JAL x0,0 |
| LED[14:0] | Lower 15 bits of last write-back result |

---

## Keypad Wiring (PMOD JA)

```
PMOD JA Header (on right side of Basys3):

  ┌─────────────────────────────────┐
  │  1    2    3    4   GND   VCC  │  ← TOP ROW
  │  J1   L2   J2   G2             │
  │                                 │
  │  7    8    9   10   GND   VCC  │  ← BOTTOM ROW
  │  H1   K2   H2   G3             │
  └─────────────────────────────────┘

KEYPAD          PMOD JA
──────          ───────
ROW 0  ──────► Pin 1  (J1)
ROW 1  ──────► Pin 2  (L2)
ROW 2  ──────► Pin 3  (J2)
ROW 3  ──────► Pin 4  (G2)
GND    ──────► GND
COL 0  ──────► Pin 7  (H1)
COL 1  ──────► Pin 8  (K2)
COL 2  ──────► Pin 9  (H2)
COL 3  ──────► Pin 10 (G3)
```
No external pull-up resistors needed — the XDC enables internal FPGA pull-ups on COL pins.

---

## File Structure

```
riscv_final/
├── src/
│   ├── top.v           ← TOP LEVEL (set as top module in Vivado)
│   ├── riscv_core.v    ← Single-cycle RV32I processor
│   ├── alu.v           ← Arithmetic Logic Unit
│   ├── alu_control.v   ← ALU control decoder
│   ├── control_unit.v  ← Main control unit
│   ├── branch_control.v← Branch condition evaluator
│   ├── imm_gen.v       ← Immediate generator
│   ├── register_file.v ← 32×32 register file
│   ├── instr_mem.v     ← Instruction ROM (pre-loaded program)
│   ├── data_mem.v      ← Data RAM
│   ├── keypad.v        ← 4×4 keypad scanner
│   └── seg7.v          ← 7-segment display driver
├── basys3.xdc          ← Pin constraints
└── tb_top.v            ← Simulation testbench
```

---

## Vivado Setup

1. **Create Project** → RTL Project → Part: `xc7a35tcpg236-1`
2. **Add Sources** → Add all `.v` files from `src/`
3. **Set Top** → Right-click `top` → Set as Top
4. **Add Constraints** → Add `basys3.xdc`
5. **Simulation** → Add `tb_top.v` as Simulation source only
6. Run Synthesis → Implementation → Generate Bitstream → Program

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Display shows AAAA | Floating col pins | Check keypad GND is connected |
| Key press not detected | ROW/COL swapped | Try swapping ROW↔COL wires |
| Result is 0 after * | Instructions not run in order | Run 0,1,2... first to fill registers |
| LED[15] on permanently | Halted at instr 15 | Press BTNU to reset |
| Timing warning in Vivado | Normal for single-cycle | Design still works correctly |
