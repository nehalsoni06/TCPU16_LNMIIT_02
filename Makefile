SRC = rtl/pmem.v rtl/loader.v rtl/dec.v rtl/alu.v rtl/npc.v rtl/omux.v rtl/toy_cpu16.v
TB  = tb/tb_toy_cpu16.v

.PHONY: all sim lint synth clean
all: lint sim synth

sim:
	iverilog -g2012 -Irtl -o sim.out $(SRC) $(TB)
	vvp sim.out | grep -E "PASS|FAIL|MISM|DONE"

lint:
	verilator --lint-only -Wall -Irtl $(SRC) --top-module toy_cpu16

synth:
	yosys -p "read_verilog -Irtl $(SRC); synth -flatten -nordff -top toy_cpu16; stat" | sed -n '/Printing statistics/,$$p' | grep -E "cells|DFF"

clean:
	rm -f sim.out *.vcd
