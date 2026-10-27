# TCPU-16: a 16-bit accumulator CPU

TCPU-16 is a very small processor written in Verilog from the micro-architecture spec TCPU16-SPEC-001 Rev 1.0. It runs a program of up to 8 one-byte instructions and leaves its result in a single 16-bit register, the accumulator. It is sized for the SkyWater SKY130 open shuttle flow (88 flip-flops).

The project contains the RTL, a self-checking testbench with a reference model, a full design document and a verification plan.

## Contents

1. [What it is](#1-what-it-is)
2. [Architecture](#2-architecture)
3. [Interface](#3-interface)
4. [Instruction set](#4-instruction-set)
5. [How it works](#5-how-it-works)
6. [How to use it](#6-how-to-use-it)
7. [Example programs](#7-example-programs)
8. [Repository layout](#8-repository-layout)
9. [Build and run](#9-build-and-run)
10. [Verification](#10-verification)
11. [Results](#11-results)
12. [Assumptions and limitations](#12-assumptions-and-limitations)
13. [Next steps](#13-next-steps)

## 1. What it is

| Item | Value |
|---|---|
| Data width | 16-bit accumulator (`acc`), the only data register |
| Instruction | 8 bits: 3-bit opcode + 5-bit operand |
| Program memory | 8 words x 8 bits (flip-flops), loaded through input ports |
| Program counter | 3 bits, wraps 7 to 0 |
| Speed | 1 instruction per clock edge (CPI = 1), no pipeline, no stalls |
| Output | 8-bit `acc_out`, one byte of `acc` chosen by `byte_sel` |
| Not included | No data RAM, no register file, no flags, no interrupts |

Because the instruction is only 8 bits, constants are limited to 0..31. Larger values are built from several instructions, for example `LOAD`, `SHL`, `ADD` gives any value up to 3999 in three instructions, and every 16-bit value needs at most five.

## 2. Architecture

```
                prog_data ───────────────┐
                                         ▼ wd
 prog_load ─┐                         ┌────────┐
 run ───────┼──► [ loader ] ─we,wa──► │  pmem  │◄── ra ── pc ──────────┐
 rst_n ─────┘                         └────┬───┘                       │
                                           │ ins                       │
                                           ▼                           │
                                      ┌────────┐  imm,t,aop   ┌───────┐│
                                      │  dec   │────────────► │  alu  ││
                                      └───┬────┘              └───┬───┘│
                                          │ jmp,jz,hlt            │ an │
                                          ▼                       │    │
                           acc ──────► [ npc ] ── pn ──┐          │    │
                                                       ▼          ▼    │
                          exec = run & ~halted ──► ┌──────────────────┐ │
                                                   │ top registers:   │─┘ pc
                                                   │ pc acc ir halted │
                                                   └────────┬─────────┘
                                                            │ acc
                                                            ▼
                                      byte_sel ───────► [ omux ] ───► acc_out[7:0]
```

The top module `toy_cpu16` owns the four architectural registers (`pc`, `acc`, `ir`, `halted`) and connects the blocks. Everything else is a separate small module:

| Module | File | Role |
|---|---|---|
| `toy_cpu16` | `rtl/toy_cpu16.v` | Top level. Registers and wiring. Updates `acc`, `pc`, `ir`, `halted` together when `exec = run & ~halted`. |
| `loader` | `rtl/loader.v` | Detects a rising edge on `prog_load` (using `plq`, the previous sample) and produces a write enable `we` and address `wa`. Holding `prog_load` high writes only one word. |
| `pmem` | `rtl/pmem.v` | 8 x 8 flip-flop memory. Combinational read (`ins = mem[pc]`), clocked write, no reset. |
| `dec` | `rtl/dec.v` | Splits the instruction into `imm` (zero-extended), `t` (jump target or shift amount) and the controls `aop`, `jmp`, `jz`, `hlt`. |
| `alu` | `rtl/alu.v` | 16-bit pass, add, subtract, shift left and XOR. Wraps modulo 65536, no flags. |
| `npc` | `rtl/npc.v` | 16-bit zero detect and next-PC select (`pc+1`, jump target, or hold). |
| `omux` | `rtl/omux.v` | Output byte mux. Purely combinational, no output register. |
| (header) | `rtl/ops.vh` | Opcode and ALU-select macros shared by `dec` and `alu`. |

`ir` holds a copy of the last committed instruction for simulation visibility only. It has no fanout, so synthesis removes it.

## Micro Architecture
<img width="1000" height="500" alt="image" src="https://github.com/user-attachments/assets/d1ad8467-e0cb-4543-ab26-44e769bf4bc0" />


## 3. Interface

| Port | Dir | Width | Description |
|---|---|---|---|
| `clk` | in | 1 | Clock. All state changes on the rising edge. |
| `rst_n` | in | 1 | Synchronous active-low reset. |
| `prog_data` | in | 8 | Instruction byte to load into program memory. |
| `prog_load` | in | 1 | Load strobe, rising edge detected. |
| `run` | in | 1 | 1 = execute one instruction per edge, 0 = pause (loading allowed). |
| `byte_sel` | in | 1 | 0 = `acc[7:0]` on `acc_out`, 1 = `acc[15:8]`. |
| `acc_out` | out | 8 | Selected accumulator byte, combinational. |

Inputs must change while `clk` is low (the design has no input synchronizers).

## 4. Instruction set

Instruction = `{opcode[7:5], operand[4:0]}`. `imm` is operand[4:0] (0 to 31, zero-extended). `sh` and `t` are operand[2:0].

| Opcode | Mnemonic | Byte range | Operation | PC after |
|---|---|---|---|---|
| 000 | LOAD imm | 0x00-0x1F | `acc <= imm` | PC+1 |
| 001 | ADD imm | 0x20-0x3F | `acc <= acc + imm` | PC+1 |
| 010 | SUB imm | 0x40-0x5F | `acc <= acc - imm` | PC+1 |
| 011 | SHL sh | 0x60-0x7F | `acc <= acc << sh` (zeros in, bits shifted out are lost) | PC+1 |
| 100 | XOR imm | 0x80-0x9F | `acc <= acc ^ imm` (only bits 4:0 change) | PC+1 |
| 101 | JMP t | 0xA0-0xBF | none | t |
| 110 | JZ t | 0xC0-0xDF | none | t if `acc == 0` (all 16 bits), else PC+1 |
| 111 | HALT | 0xE0-0xFF | `halted <= 1` | held |

Details worth knowing:

- ADD and SUB wrap modulo 65536. A carry or borrow crosses from bit 7 into bit 8 because the adder is 16 bits wide. There are no carry, borrow or zero flags.
- JZ tests `acc` as left by the previous instruction, so `SUB 1` followed by `JZ` tests the subtraction result. It checks all 16 bits, so 0x0100 is not zero.
- Operand bits [4:3] are ignored by SHL, JMP and JZ, and the whole operand is ignored by HALT.
- HALT is sticky. Only `rst_n` clears it. `run` toggles and program loading do not restart execution.
- At address 7 a non-jump instruction wraps the PC to 0. This is not a halt.

## 5. How it works

### One clock edge

1. `pmem` outputs the instruction at the current `pc`.
2. `dec` splits it and raises the controls.
3. `alu` computes the new accumulator value `an`, and `npc` computes the next PC `pn`.
4. At the rising edge, if `exec = 1`, the top level writes `acc`, `pc`, `ir` and `halted` together.
5. `acc_out` follows `acc` straight away, with no extra cycle.

### What happens at each edge, in priority order

| Priority | Condition | Action |
|---|---|---|
| 1 | `rst_n = 0` | Clear `acc`, `pc`, `ir`, `halted` and the load address. Program memory is kept. Load pulses are ignored. |
| 2 | `run = 0` and a load pulse | Write `prog_data` to `mem[la]` and increment `la`. CPU state is unchanged. |
| 3 | `run = 1`, not halted | Commit one instruction. |
| 4 | `run = 1`, halted | No change. |
| 5 | `run = 0`, no pulse | No change (pause). Resumes from the held `pc`. |

A load pulse while `run = 1` is ignored. A 9th loaded word overwrites word 0.

### Why the output is a mux

`acc_out` is only 8 bits wide, so a 16-bit result takes two reads. The mux is purely combinational, so `byte_sel` takes effect without a clock edge and the new `acc` is visible immediately after a commit. The two reads must happen while `acc` is not changing (with `run = 0`, after HALT, or between single-stepped clocks), otherwise the two bytes can belong to different values.

## 6. How to use it

1. Reset (`rst_n` low for 2 or more edges) with `run = 0`, then release.
2. Load all 8 words. For each word: set `prog_data`, raise `prog_load` for at least 1 edge, lower it for at least 1 edge. Keep `prog_data` stable while `prog_load` is high.
3. Set `run = 1` and clock the design. Execution starts at word 0.
4. When the program has halted (or `run = 0`), read the result: `byte_sel = 0` for the low byte, then `byte_sel = 1` for the high byte.

All 8 words must be loaded before running. Memory has no reset, so unloaded words are undefined.

## 7. Example programs

### Build 0x0123 and count down by three (spec section 8.1)

| Addr | Instruction | Hex |
|---|---|---|
| 0 | LOAD 18 | 0x12 |
| 1 | SHL 4 | 0x64 |
| 2 | ADD 3 | 0x23 |
| 3 | SUB 1 | 0x41 |
| 4 | SUB 1 | 0x41 |
| 5 | SUB 1 | 0x41 |
| 6 | HALT | 0xE0 |
| 7 | HALT (filler) | 0xE0 |

`acc` after each edge: 0x0012, 0x0120, 0x0123, 0x0122, 0x0121, 0x0120, then frozen at 0x0120 with `pc` held at 6. Reading `acc_out` gives 0x20 (`byte_sel = 0`) and 0x01 (`byte_sel = 1`).

### Countdown loop (spec section 8.2)

| Addr | Instruction | Hex |
|---|---|---|
| 0 | LOAD 3 | 0x03 |
| 1 | SUB 1 | 0x41 |
| 2 | JZ 4 | 0xC4 |
| 3 | JMP 1 | 0xA1 |
| 4-7 | HALT | 0xE0 |

`acc` counts 3, 2, 1, 0. JZ is not taken twice and taken once; the CPU halts at cycle 10 with `acc = 0` and `pc` held at 4.


## 8. Build and run

Requires `iverilog`, `verilator` and `yosys`.

```
make lint    # Verilator --lint-only -Wall
make sim     # directed tests plus 1000 random programs against the reference model
make synth   # Yosys: flop count and cell count
make         # all three
make clean
```

## 9. Verification

The testbench `tb/tb_toy_cpu16.v` has three parts:

- **Reference model.** A behavioural copy of the spec's per-edge algorithm. After every clock edge the testbench compares `pc`, `acc`, `ir`, `halted` and `acc_out` between the design and the model, and checks for X values after reset and load.
- **Directed tests.** Both spec programs (8.1 and 8.2), halt freeze and stickiness, reset keeping the program, 9th-load wrap, load while halted, loads ignored while running, reset during a load, JZ on all 16 single-bit values, and ignored operand bits for SHL, JMP, JZ and HALT.
- **Random regression.** 1000 random programs of 64 edges, with random `run`, `rst_n`, `prog_load` and `byte_sel` activity, compared against the model on every edge.

The full plan is in `docs/TCPU16_Verification_Plan.md`. It lists every feature with sub-features, test names, scenarios, positive or negative type, cover points, configuration, cross-feature checks, 24 assertions and the functional coverage groups. Each test is marked Done, Rand (covered only by the random run) or Plan (not yet written).

## 10. Results

| Check | Result |
|---|---|
| Verilator `--lint-only -Wall` | Clean |
| Simulation | 0 errors |
| Yosys `synth -flatten -nordff` | 88 flops, no latches, 498 generic cells |

The spec expects 88 flops. With default `synth -flatten` Yosys reports 91 because it duplicates `pc` as a memory read-address register; `-nordff` prevents that.

## 11. Assumptions and limitations

- The spec's two clocking modes are not used. There are no input synchronizers, so the design behaves as the host-generated-clock mode and inputs must change only while `clk` is low.
- The clock period, PVT corners, harness pin mapping and area allocation are not declared yet, so there is no timing analysis or physical flow in this repo.
- The assertions and covergroups in the verification plan are specified but not yet written as code. Several planned directed tests are still open.
- Sub-module and signal names are shortened for readability. The top-level port names and `pc`, `acc`, `ir`, `halted` keep the spec names, as the spec requires.
- Hardware limits: only 8 instruction words, constants of 0..31 per instruction, no program readback and no halted status pin.

## 12. Next steps

1. Write the assertions and functional coverage as SystemVerilog and add the remaining directed tests from the plan.
2. Declare a clock period, corners and harness, then run the SKY130 flow (for example OpenLane or Tiny Tapeout) and record the timing results.
3. Optionally run a gate-level simulation of the section 8.1 program on the synthesized netlist.

## Reference

Spec: TCPU16-SPEC-001 Rev 1.0, "TCPU-16: 16-bit Accumulator, 8-bit Instruction, Single-Cycle CPU, Micro-architecture Specification".
