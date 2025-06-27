yosys -import
read_verilog $::env(VERILOG_DIR)/$::env(DESIGN_NAME)_mod.v
hierarchy -top $::env(DESIGN_NAME)
write_verilog $::env(RESULTS_DIR)/1_synth.v