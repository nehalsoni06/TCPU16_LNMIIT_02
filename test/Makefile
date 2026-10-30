a
IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
YOSYS     ?= yosys
GTKWave   ?= gtkwave

RTL := src/pmem.v \
       src/loader.v \
       src/dec.v \
       src/alu.v \
       src/npc.v \
       src/omux.v \
       src/toy_cpu16.v \
       src/project.v

BUILD := build
SIM := $(BUILD)/tb_toy_cpu16
WAVE := $(BUILD)/tcpu16_wave.vcd

.PHONY: all sim wave view lint synth clean

all: lint sim

$(BUILD):
	mkdir -p $(BUILD)

sim: $(BUILD)
	$(IVERILOG) -g2012 -Isrc -s tb_toy_cpu16 \
	-o $(SIM) $(RTL) tb/tb_toy_cpu16.v
	$(VVP) $(SIM)

wave: sim
	$(GTKWave) $(WAVE)

view:
	$(GTKWave) $(WAVE)

lint:
	$(VERILATOR) --lint-only -Wall -Wno-fatal \
	-Isrc --top-module tt_um_nehalsoni06_tcpu16 $(RTL)

synth:
	$(YOSYS) -p 'read_verilog -Isrc $(RTL); hierarchy -top tt_um_nehalsoni06_tcpu16; synth -top tt_um_nehalsoni06_tcpu16 -flatten -noabc -nordff; stat'

clean:
	rm -rf $(BUILD) obj_dir

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
