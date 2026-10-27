
IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
YOSYS     ?= yosys
GTKWave   ?= gtkwave

RTL := rtl/pmem.v \
       rtl/loader.v \
       rtl/dec.v \
       rtl/alu.v \
       rtl/npc.v \
       rtl/omux.v \
       rtl/toy_cpu16.v

BUILD := build
SIM := $(BUILD)/tb_toy_cpu16
WAVE := $(BUILD)/tcpu16_wave.vcd

.PHONY: all sim wave view lint synth clean

all: lint sim

$(BUILD):
	mkdir -p $(BUILD)

sim: $(BUILD)
	$(IVERILOG) -g2012 -Irtl -s tb_toy_cpu16 \
	-o $(SIM) $(RTL) tb/tb_toy_cpu16.v
	$(VVP) $(SIM)

wave: sim
	$(GTKWave) $(WAVE)

view:
	$(GTKWave) $(WAVE)

lint:
	$(VERILATOR) --lint-only -Wall -Wno-fatal \
	-Irtl --top-module toy_cpu16 $(RTL)

synth:
	$(YOSYS) -p 'read_verilog -Irtl $(RTL); hierarchy -top toy_cpu16; synth -top toy_cpu16 -flatten -noabc -nordff; stat'

clean:
	rm -rf $(BUILD) obj_dir
