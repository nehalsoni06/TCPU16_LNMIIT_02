
# Sample testbench for a Tiny Tapeout project

This is the testbench for the TCPU-16 Tiny Tapeout project. It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.
See below to get started or for more information, check the [website](https://tinytapeout.com/hdl/testing/).

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to point to your Verilog files:
   - `../src/project.v`
   - `../src/toy_cpu16.v`
   - `../src/alu.v`
   - `../src/dec.v`
   - `../src/loader.v`
   - `../src/npc.v`
   - `../src/omux.v`
   - `../src/pmem.v`

2. Edit [tb.v](tb.v) and replace `tt_um_example` with `tt_um_nehalsoni06_tcpu16`.

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/tt_um_nehalsoni06_tcpu16.v` to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

If you wish to save the waveform in VCD format instead of FST format, edit tb.v to use `$dumpfile("tb.vcd");` and then run:

```sh
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave

```sh
gtkwave tb.fst tb.gtkw
```

Using Surfer

```sh
surfer tb.fst
```
