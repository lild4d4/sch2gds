# SCH2GDS 

This is a flow that allows the designer to go from a schematic with only standarcells to the LVS.

## Steps

### Schematic to verilog

First is necessary to extract the verilog netlist from the schematic. This can be done using the terminal or the gui
1. The comand
``` bash
export XSCHEM_ARGS = -n -r -x -q

xschem $(XSCHEM_ARGS) -w $(XSCHEM_RCFILE) -o $(VERILOG_DIR) $(XSCHEM_DIR)/$(DESIGN_NAME).sch
```
### Canonicalize the verilog file
Since normally in the schematic power pins are added, but in the verilog aren't required is necessary to remove them from the verilog file resulting from xschem. Also It is recommended to add the directive ```(* keep *)(* dont_touch = "true" *)``` over the standar cells so they dont get optimized away during the librelane process.

``` bash
python3 $(SCRIPTS_DIR)/verilog-canonicalize.py $(VERILOG_DIR)/$(DESIGN_NAME).v $(VERILOG_DIR)/$(DESIGN_NAME)_mod.v "VCC" "VSS"
```
### Run Librelane
In order to run the process succesfully in librelane a few specific configurations are requeried.
1. The followinf configuration must be added in order skip the buffers that may get added during the librelane flow:
```json
"SYNTH_DIRECT_WIRE_BUFFERING": false,
"PL_TIME_DRIVEN": false,
```
2. The filling step must be skipped in order to pass LVS, since the fillers added by librelane are then extracted as transistor we dont want.
```
"OpenROAD.FillInsertion": null,
```
3. the repair design after globalplacement must be also skiped since this added buffer in oprder to optimice timing.
```
"OpenROAD.RepairDesignPostGPL": null
```
Finally, librelane can be lunch with the following command:
```bash
librelane config.json --run-tag sch2gds --overwrite
```
### Do LVS
1. In order to make LVS it is necessary to extract the lvs-spice from xschem. This can be done with the following command:
```bash
xschem $(XSCHEM_ARGS) $(XSCHEM_RCFILE) --netlist_path $(SPICE_DIR)/$(DESIGN_NICKNAME) --preinit 'set lvs_netlist 1' $(XSCHEM_DIR)/$(DESIGN_NAME).sch
```
2. Then since in the schematic were added just the standard cells, the actual spice implementation of this cells must be added to the spice file with the M prefix:

```bash
python3 $(SCRIPTS_DIR)/merge_stdcells.py $(SPICE_DIR)/$(DESIGN_NICKNAME)/DB.spice $(STDCELL_LIB) $(SPICE_DIR)/$(DESIGN_NICKNAME)/merged_$(DESIGN_NAME).spice
```

Finally, the LVS can be done in KLayout comparing the gds and the file *merged_$(DESIGN_NAME).spice*

# Quick Run

The flow is builded over an example, in order to run it with a custom design it is requerid to change the variables of the beggining of the makefile and the design name inside the config.json