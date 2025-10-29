export DESIGN_NICKNAME=Digital_Block
export DESIGN_NAME=DB
export DESIGN_HOME=$(shell pwd)

export XSCHEM_DIR = xschem/$(DESIGN_NICKNAME)
export VERILOG_DIR = $(DESIGN_HOME)/verilog/$(DESIGN_NICKNAME)
export SCRIPTS_DIR = scripts
export GDS_DIR = klayout/gds/$(DESIGN_NICKNAME)
export LVS_DIR = klayout/lvs/$(DESIGN_NICKNAME)
export SPICE_DIR = spice

export XSCHEM_ARGS = -n -r -x -q
export XSCHEM_RCFILE = --rcfile $(PDK_ROOT)/$(PDK)/libs.tech/xschem/xschemrc

export STDCELL_LIB = $(PDK_ROOT)/$(PDK)/libs.ref/sg13g2_stdcell/spice/sg13g2_stdcell.spice

export RESULTS_DIR = $(DESIGN_HOME)/results/$(DESIGN_NICKNAME)

.PHONY: all
all: sch2gds do-extract-spice do-stdcell-merge

# ==============================================================================
#   _____  _____ _    _ ___   _____ _____   _____ 
#  / ____|/ ____| |  | |__ \ / ____|  __ \ / ____|
# | (___ | |    | |__| |  ) | |  __| |  | | (___  
#  \___ \| |    |  __  | / /| | |_ | |  | |\___ \ 
#  ____) | |____| |  | |/ /_| |__| | |__| |____) |
# |_____/ \_____|_|  |_|____|\_____|_____/|_____/ 
#
.PHONY: sch2gds
sch2gds: final/gds/$(DESIGN_NAME).gds

# ==============================================================================

.PHONY: do-librelane
do-librelane:
	librelane config.json --run-tag sch2gds --overwrite
	cp -r runs/sch2gds/final .

.PHONY: do-verilog-canonicalize
do-verilog-canonicalize:
	python3 $(SCRIPTS_DIR)/verilog-canonicalize.py $(VERILOG_DIR)/$(DESIGN_NAME).v $(VERILOG_DIR)/$(DESIGN_NAME)_mod.v "VCC" "VSS"

.PHONY: do-verilog-from-xschem
do-verilog-from-xschem:
	mkdir -p $(VERILOG_DIR)
	xschem $(XSCHEM_ARGS) -w $(XSCHEM_RCFILE) -o $(VERILOG_DIR) $(XSCHEM_DIR)/$(DESIGN_NAME).sch

.PHONY: do-extract-spice
do-extract-spice:
	mkdir -p $(SPICE_DIR)/$(DESIGN_NICKNAME)
	xschem $(XSCHEM_ARGS) $(XSCHEM_RCFILE) --netlist_path $(SPICE_DIR)/$(DESIGN_NICKNAME) --preinit 'set lvs_netlist 1' $(XSCHEM_DIR)/$(DESIGN_NAME).sch

.PHONY: do-stdcell-merge
do-stdcell-merge:
	python3 $(SCRIPTS_DIR)/merge_stdcells.py $(SPICE_DIR)/$(DESIGN_NICKNAME)/DB.spice $(STDCELL_LIB) $(SPICE_DIR)/$(DESIGN_NICKNAME)/merged_$(DESIGN_NAME).spice

final/gds/$(DESIGN_NAME).gds: $(VERILOG_DIR)/$(DESIGN_NAME)_mod.v
	make do-librelane

$(VERILOG_DIR)/$(DESIGN_NAME)_mod.v: $(VERILOG_DIR)/$(DESIGN_NAME).v
	make do-verilog-canonicalize

$(VERILOG_DIR)/$(DESIGN_NAME).v: $(XSCHEM_DIR)/$(DESIGN_NAME).sch
	mkdir -p $(VERILOG_DIR)
	make do-verilog-from-xschem
