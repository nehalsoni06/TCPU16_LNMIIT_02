
# TCPU-16 Instruction Set

## 1. Overview

TCPU-16 is a 16-bit accumulator-based processor that uses 8-bit instructions. Each instruction contains an opcode and an operand.

The instruction format is:

```text
  7 6 5 4 3 2 1 0
 +---------+-----+
 |  Opcode |Operand
 +---------+-----+
    3 bits  5 bits
```

- **Opcode:** Bits `[7:5]` identify the operation.
- **Operand:** Bits `[4:0]` provide the immediate value, shift amount, or jump address, depending on the instruction.

## 2. Instruction Set

| Opcode `[7:5]` | Instruction | Operation | Description |
|---|---|---|---|
| `000` | LOAD | `ACC = operand` | Loads an immediate value into the accumulator. |
| `001` | ADD | `ACC = ACC + operand` | Adds the operand to the accumulator. |
| `010` | SUB | `ACC = ACC - operand` | Subtracts the operand from the accumulator. |
| `011` | SHL | `ACC = ACC << operand` | Shifts the accumulator left by the specified amount. |
| `100` | XOR | `ACC = ACC ^ operand` | Performs a bitwise XOR between the accumulator and operand. |
| `101` | JMP | `PC = operand` | Jumps to the specified program-memory address. |
| `110` | JZ | If `ACC == 0`, `PC = operand` | Jumps when the accumulator is zero. |
| `111` | HALT | Stop execution | Halts the processor. |

**Note:** The operation descriptions above show the intended instruction behavior. Immediate-value extension, result truncation, program-counter updates, and HALT behavior should match the RTL implementation.

## 3. Instruction Encoding

An instruction is encoded by placing the 3-bit opcode in bits `[7:5]` and the 5-bit operand in bits `[4:0]`.

For example:

```text
Instruction: ADD 3

Opcode  = 001
Operand = 00011

Binary instruction = 00100011
Hex instruction    = 0x23
```

Another example:

```text
Instruction: SUB 1

Opcode  = 010
Operand = 00001

Binary instruction = 01000001
Hex instruction    = 0x41
```

## 4. Example Program

The following program constructs the value `0x0123`, subtracts `3`, and halts with the accumulator equal to `0x0120`.

| Address | Hex Code | Instruction | Purpose |
|---:|---|---|---|
| 0 | `0x12` | LOAD 18 | Load decimal 18 (`0x12`). |
| 1 | `0x64` | SHL 4 | Shift left by 4 bits, producing `0x0120`. |
| 2 | `0x23` | ADD 3 | Add 3, producing `0x0123`. |
| 3 | `0x41` | SUB 1 | Subtract 1, producing `0x0122`. |
| 4 | `0x41` | SUB 1 | Subtract 1, producing `0x0121`. |
| 5 | `0x41` | SUB 1 | Subtract 1, producing `0x0120`. |
| 6 | `0xE0` | HALT | Stop execution. |
| 7 | `0x00` | LOAD 0 | Unused filler instruction. |

### Expected Result

```text
ACC = 0x0120

byte_sel = 0  -> acc_out = 0x20
byte_sel = 1  -> acc_out = 0x01
```

## 5. Program Memory

The program memory contains 8 instruction words, addressed from `0` to `7`.

- Each instruction is 8 bits wide.
- The program counter selects the instruction address.
- Instructions execute according to the CPU control logic.
- JMP and JZ modify the program flow according to their specified conditions.
- HALT stops further instruction execution.

## 6. Related Files

- `alu.v` — implements arithmetic and logical operations.
- `dec.v` — decodes the instruction opcode.
- `prog_mem.v` — stores and supplies program instructions.
- `toy_cpu16.v` — integrates the processor modules.
- `alu.md` — documents the ALU and its block diagram.
