# TCPU-16 Testbench

This is the testbench for the TCPU-16 project submitted to Tiny Tapeout. It uses [Cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and verify its outputs.

TCPU-16 is a 16-bit educational CPU featuring an ALU, an 8-bit instruction memory, a program loader, and an accumulator.

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to include the TCPU-16 Verilog source files.
2. Edit [tb.v](tb.v) and ensure that the instantiated module name is `tt_um_nehalsoni06_tcpu16`.
3. Edit [test.py](test.py) to implement the Cocotb test cases for the CPU.

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gate-level simulation, first harden your project and copy the generated gate-level netlist to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

The gate-level simulation uses the GF180MCU PDK libraries configured in the Makefile.

If you wish to save the waveform in VCD format instead of FST format, edit `tb.v` to use `$dumpfile("tb.vcd");` and then run:

```sh
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave:

```sh
gtkwave tb.fst
```

Using Surfer:

```sh
surfer tb.fst
```

## Testbench details

The Cocotb testbench drives the clock, reset, and input signals of the TCPU-16 wrapper. Test cases can be added to verify instruction loading, CPU execution, accumulator updates, and other processor operations.
