
# Tool configuration
IVERILOG  ?= iverilog
VVP       ?= vvp
VERILATOR ?= verilator
YOSYS     ?= yosys
GTKWave   ?= gtkwave

# Project source files
PROJECT_SOURCES = ../src/project.v \
                  ../src/toy_cpu16.v \
                  ../src/alu.v \
                  ../src/dec.v \
                  ../src/loader.v \
                  ../src/npc.v \
                  ../src/omux.v \
                  ../src/pmem.v

# Build configuration
BUILD := build
SIM := $(BUILD)/tb_toy_cpu16
WAVE := $(BUILD)/tcpu16_wave.vcd

.PHONY: all sim wave view lint synth clean

all: lint sim

$(BUILD):
	mkdir -p $(BUILD)

sim: $(BUILD)
	$(IVERILOG) -g2012 -Isrc -s tb \
	-o $(SIM) $(PROJECT_SOURCES) tb.v
	$(VVP) $(SIM)

wave: sim
	$(GTKWave) $(WAVE)

view:
	$(GTKWave) $(WAVE)

lint:
	$(VERILATOR) --lint-only -Wall -Wno-fatal \
	--top-module tt_um_nehalsoni06_tcpu16 $(PROJECT_SOURCES)

synth:
	$(YOSYS) -p 'read_verilog $(PROJECT_SOURCES); hierarchy -top tt_um_nehalsoni06_tcpu16; synth -top tt_um_nehalsoni06_tcpu16 -flatten -noabc -nordff; stat'

clean:
	rm -rf $(BUILD) obj_dir
