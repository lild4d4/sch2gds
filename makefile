include $(DESIGN_CONFIG)

export XSCHEM_DIR = xschem/$(DESIGN_NICKNAME)
export VERILOG_DIR = $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)
export SCRIPTS_DIR = scripts
export GDS_DIR = klayout/gds/$(DESIGN_NICKNAME)
export LVS_DIR = klayout/lvs/$(DESIGN_NICKNAME)
export NETLIST_DIR = netlist

export XSCHEM_ARGS = -n -r -x -q
export XSCHEM_RCFILE = --rcfile $(PDK_ROOT)/$(PDK)/libs.tech/xschem/xschemrc

export RESULTS_DIR = $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN_NICKNAME)/base

.PHONY: all
all: sch2gds

# ==============================================================================
#   _____  _____ _    _ ___   _____ _____   _____ 
#  / ____|/ ____| |  | |__ \ / ____|  __ \ / ____|
# | (___ | |    | |__| |  ) | |  __| |  | | (___  
#  \___ \| |    |  __  | / /| | |_ | |  | |\___ \ 
#  ____) | |____| |  | |/ /_| |__| | |__| |____) |
# |_____/ \_____|_|  |_|____|\_____|_____/|_____/ 
#
.PHONY: sch2gds
sch2gds: $(GDS_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).gds

# ==============================================================================

.PHONY: do-gds
do-gds: $(RESULTS_DIR)/sg13g2.map
	-make -B -C $(ORFS_ROOT)/flow do-gds
	cp $(RESULTS_DIR)/6_1_merged.gds $(RESULTS_DIR)/6_final.gds
	cp $(RESULTS_DIR)/6_final.gds $(GDS_DIR)/$(DESIGN_NAME).gds

.PHONY: do-openroad
do-openroad:
	mkdir -p $(RESULTS_DIR)
	openroad $(SCRIPTS_DIR)/v2p.tcl

.PHONY: do-yosys-canonicalize
do-yosys-canonicalize:
	mkdir -p $(RESULTS_DIR)
	yosys -v -c $(SCRIPTS_DIR)/yosys-canonicalize.tcl

.PHONY: do-verilog-canonicalize
do-verilog-canonicalize:
	python3 $(SCRIPTS_DIR)/verilog-canonicalize.py $(VERILOG_DIR)/$(DESIGN_NAME).v $(VERILOG_DIR)/$(DESIGN_NAME)_mod.v

.PHONY: do-verilog-from-xschem
do-verilog-from-xschem:
	xschem $(XSCHEM_ARGS) -w $(XSCHEM_RCFILE) -o $(VERILOG_DIR) $(XSCHEM_DIR)/$(DESIGN_NAME).sch

$(GDS_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).gds: $(RESULTS_DIR)/6_final.def
	make do-gds
	
$(RESULTS_DIR)/6_final.def: $(RESULTS_DIR)/1_synth.v
	make do-openroad

$(RESULTS_DIR)/1_synth.v: $(VERILOG_DIR)/$(DESIGN_NAME)_mod.v
	make do-yosys-canonicalize

$(VERILOG_DIR)/$(DESIGN_NAME)_mod.v: $(VERILOG_DIR)/$(DESIGN_NAME).v
	make do-verilog-canonicalize

$(VERILOG_DIR)/$(DESIGN_NAME).v: $(XSCHEM_DIR)/$(DESIGN_NAME).sch
	make do-verilog-from-xschem

$(RESULTS_DIR)/sg13g2.map:
	mkdir -p $(RESULTS_DIR)
	cp $(ORFS_ROOT)/flow/platforms/$(PDK)/sg13g2.map $(RESULTS_DIR)/sg13g2.map

.PHONY: lvs
lvs: $(LVS_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).lvsdb

.PHONY: do-lvs
do-lvs:
	echo 'hello'
	

.PHONY: do-extract-netlist
do-extract-netlist:
	xschem $(XSCHEM_ARGS) $(XSCHEM_RCFILE) --netlist_path $(NETLIST_DIR)/$(DESIGN_NICKNAME) --preinit 'set lvs_netlist 1' $(XSCHEM_DIR)/$(DESIGN_NAME).sch


$(LVS_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).lvsdb: $(NETLIST_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).spice
	do-lvs

$(NETLIST_DIR)/$(DESIGN_NICKNAME)/$(DESIGN_NAME).spice: 
	do-extract-netlist

