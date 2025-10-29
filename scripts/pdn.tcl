# stdcell power pins
add_global_connection -net {VDD} -pin_pattern {^VDD$} -power
add_global_connection -net {VDD} -pin_pattern {^VDDPE$}
add_global_connection -net {VDD} -pin_pattern {^VDDCE$}

add_global_connection -net {VSS} -pin_pattern {^VSS$} -ground
add_global_connection -net {VSS} -pin_pattern {^VSSE$}

global_connect

# Create a region covering the full core area
set region [odb::dbRegion_create [ord::get_db_block] Die]

set core_area [[ord::get_db_block] getCoreArea]

puts $core_area
puts [$core_area xMin]
puts [$core_area yMin]
puts [$core_area xMax]
puts [$core_area yMax]


odb::dbBox_create $region {362} {362} {2138} {2138}
#[$core_area xMin] [$core_area yMin] [$core_area xMax] [$core_area yMax]

# core voltage domain
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}

# stdcell grid
define_pdn_grid -name {grid} -voltage_domains {CORE}
add_pdn_ring \
	-grid {grid} \
	-layers {TopMetal1 TopMetal2} \
	-widths {15.0} \
	-spacings {2.0} \
	-core_offsets {4.5} \
	-connect_to_pads
add_pdn_stripe \
	-grid {grid} \
	-layer {Metal1} \
	-width {0.44} \
	-pitch {7.56} \
	-offset {0} \
	-followpins \
	-extend_to_core_ring
add_pdn_stripe \
	-grid {grid} \
	-layer {TopMetal1} \
	-width {5.000} \
	-pitch {75.6} \
	-offset {13.600} \
	-extend_to_core_ring
add_pdn_stripe \
	-grid {grid} \
	-layer {TopMetal2} \
	-width {5.000} \
	-pitch {75.6} \
	-offset {13.600} \
	-extend_to_core_ring
add_pdn_connect -grid {grid} -layers {Metal1 TopMetal1}
add_pdn_connect -grid {grid} -layers {TopMetal1 TopMetal2}