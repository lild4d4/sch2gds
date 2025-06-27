read_lef $::env(IHP_PDK_ROOT)/$::env(PDK)/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef $::env(IHP_PDK_ROOT)/$::env(PDK)/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_lef $::env(IHP_PDK_ROOT)/$::env(PDK)/libs.ref/sg13g2_io/lef/sg13g2_io.lef

read_liberty $::env(IHP_PDK_ROOT)/$::env(PDK)/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_liberty $::env(IHP_PDK_ROOT)/$::env(PDK)/libs.ref/sg13g2_io/lib/sg13g2_io_dummy.lib  

read_verilog $::env(RESULTS_DIR)/1_synth.v
link_design $::env(DESIGN_NAME)

#floorplan
initialize_floorplan -die_area "0 0 70 70" \
  -core_area "0 0 70 70" \
  -site CoreSite
cut_rows

make_tracks

source $::env(DESIGN_HOME)/$::env(PLATFORM)/$::env(DESIGN_NICKNAME)/pdn.tcl
pdngen

place_pins -random -hor_layer Metal2 -ver_layer Metal3

#place
global_placement -density 0.6 -init_density_penalty 0.01 -skip_initial_place
detailed_placement

#routing
set_routing_layers -signal Metal1-Metal5
global_route
detailed_route

write_def  $::env(RESULTS_DIR)/6_final.def