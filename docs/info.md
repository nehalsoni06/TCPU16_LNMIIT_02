
<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

TCPU-16 is a simple 16-bit educational CPU with an 8-bit instruction format. It consists of an instruction memory, instruction decoder, arithmetic logic unit (ALU), program counter, accumulator, program loader, and output multiplexer.

The CPU uses an 8-bit instruction memory containing 8 instruction locations. Instructions are loaded through the `prog_data` input using the `prog_load` control signal. The program loader detects the rising edge of `prog_load` and generates a write-enable pulse to store instructions sequentially in memory.

During execution, the program counter (PC) selects the instruction from program memory. The instruction decoder extracts the operation type, immediate value, and control signals required for execution.

The ALU performs the operation specified by the decoded instruction using the current accumulator value and immediate operand. The result is stored in the 16-bit accumulator on the rising edge of the clock.

The next-PC logic determines the next instruction address based on the instruction type. It supports sequential execution, unconditional jumps, conditional jumps based on the accumulator being zero, and halt operations.

The `run` signal enables instruction execution. The `rst_n` signal resets the accumulator, program counter, instruction register, and halt status. Program memory is not cleared during reset, allowing a previously loaded program to be executed again.

The output multiplexer selects either the lower or upper 8 bits of the accumulator using the `byte_sel` input and provides the selected byte through `acc_out`.

## How to test

1. Apply the clock signal to `clk`.
2. Apply an active-low reset using `rst_n` to initialize the CPU.
3. Set `run` low before loading the program.
4. Provide an 8-bit instruction on `prog_data`.
5. Generate a rising edge on `prog_load` for each instruction to write it into program memory. Load instructions sequentially.
6. After loading the program, keep `prog_load` low and set `run` high to start execution.
7. Observe the accumulator output through `uo_out`.
8. Use `byte_sel` to select the lower or upper 8 bits of the 16-bit accumulator.
9. The CPU stops executing when a HALT instruction is encountered. Apply reset to restart execution from address zero while retaining the loaded program.

The design can be simulated using Icarus Verilog and its waveforms can be inspected using GTKWave.

## External hardware

No external hardware is required. The design uses the standard Tiny Tapeout input, output, bidirectional, clock, and reset pins.
