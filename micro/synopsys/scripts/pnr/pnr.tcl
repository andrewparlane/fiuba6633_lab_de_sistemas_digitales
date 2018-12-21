#####################################################################################
#
# Description:
# ------------
#
# Run Synopsys IC Compiler script.
#
#####################################################################################

#################################################################################
# Initialization message
#################################################################################
puts ""
puts ""
puts ""
puts "INFO: Starting place and route process."

#################################################################################
# Reference paths
#################################################################################
set scripts_path "../../../scripts/pnr"

#################################################################################
# Technology settings
#################################################################################
if {[file exists ../../../scripts/common/digtech_settings.tcl]} {
   source ../../../scripts/common/digtech_settings.tcl
} else {
   puts "ERROR: file 'digtech_settings.tcl' doesn't exist."
}

#################################################################################
# Load synthesis options
#################################################################################
if {[file exists ../../../scripts/syn/syn_setup.tcl]} {
   source ../../../scripts/syn/syn_setup.tcl
   puts "INFO: 'syn_setup.tcl' file sourced."
} else {
   puts "ERROR: file 'syn_setup.tcl' doesn't exist."
}

#################################################################################
# report synthesis options
#################################################################################
puts "INFO: Reporting synthesis options."
puts ""
puts "     ----- Optimization options -----"
puts "      - flat_design          : ${flat_design}"
puts "      - constraint_design    : ${constraint_design}"
puts "      - constraints_first    : ${constraints_first}"
puts "      - remove_assigns       : ${remove_assigns}"
puts ""
puts "     ----- Low power options -----"
puts "      - insert_clk_gating    : ${insert_clk_gating}"
puts "      - clk_gating_min_num   : ${clk_gating_min_num}"
puts "      - dynamic_optimization : ${dynamic_optimization}"
puts "      - xor_gating           : ${xor_gating}"
puts ""
puts "     ----- DFT options -----"
puts "      - scan_design          : ${scan_design}"
puts "      - scan_chains_num      : ${scan_chains_num}"
puts "      - non_inverting_scan   : ${non_inverting_scan}"
puts "      - fix_dft_violations   : ${fix_dft_violations}"
puts ""

###############################################################################
# Library setup
###############################################################################
puts "INFO: Setting up libraries..."
set_app_var       search_path        "${search_paths}"
set_app_var       target_library      ${target_max_libs}
set_app_var       synthetic_library   ${dw_foundation_lib}
set_app_var       link_library        "* ${target_max_libs} ${synthetic_library}"
set lib_idx 0
foreach max_lib ${target_max_libs} {
   set min_lib [lindex ${target_min_libs} ${lib_idx}]
   set_min_library   ${max_lib} -min_version ${min_lib}
   set lib_idx [expr ${lib_idx} + 1]
}
set_app_var symbol_library ${generic_lib}
set mw_design_lib ../../../dgen/pnr/db/mw/${block_name}

if {![file isdirectory ${mw_design_lib}]} {
   create_mw_lib -technology ${mw_techfile} -mw_reference_library ${milkyway_ref_lib} ${mw_design_lib}
} else {
   sh rm -rf ${mw_design_lib}
   create_mw_lib -technology ${mw_techfile} -mw_reference_library ${milkyway_ref_lib} ${mw_design_lib}
}
open_mw_lib ${mw_design_lib}
check_library
set_tlu_plus_files \
   -max_tluplus ${tlup_max_file} \
   -min_tluplus ${tlup_min_file} \
   -tech2itf_map  ${tech2itf_file}
check_tlu_plus_files
import_designs -format ddc -top ${block_name} -cel ${block_name} "../../../dgen/syn/db/mapped/${block_name}.ddc"
check_timing > ../../../dgen/pnr/reports/check_timing.rpt

###############################################################################
# Setting delay calculation method
###############################################################################
set_delay_calculation_options -preroute awe -awe_effort high
set_delay_calculation_options -routed_clock arnoldi
set_delay_calculation_options -postroute arnoldi

###############################################################################
# Operating conditions and analysis type
###############################################################################
set_operating_conditions \
   -analysis_type bc_wc \
   -max ${max_oper_cond} -min ${min_oper_cond}

###############################################################################
# Save design
###############################################################################
save_design_settings -library
save_mw_cel  -design "${block_name}.CEL;1"
close_mw_cel
close_mw_lib

###############################################################################
# Listing libraries
###############################################################################
puts "INFO: Listing used libraries."
list_libs
puts ""

# ###############################################################################
# # FLOORPLANNING
# ###############################################################################
copy_mw_cel     \
   -from_library ${mw_design_lib} \
   -from ${block_name} \
   -to_library ${mw_design_lib} \
   -to ${block_name}_floorplan

set ::auto_restore_mw_cel_lib_setup false
open_mw_cel  ${block_name}_floorplan
current_mw_cel ${block_name}_floorplan

if {[file exists ${scripts_path}/floorplan.tcl]} {
   sh rm -f ${scripts_path}/floorplan.tcl
}

puts "INFO: Creating new floorplan."
create_floorplan \
   -core_utilization 0.8 \
   -core_aspect_ratio 0.4 \
   -left_io2core 16 \
   -bottom_io2core 16 \
   -right_io2core 16 \
   -top_io2core 16
puts "INFO: Floorplan created."

derive_pg_connection -power_net {vdd} -ground_net {gnd} -create_ports top
derive_pg_connection -power_net {vdd} -ground_net {gnd} -tie

create_rectangular_rings \
   -around core \
   -nets {vdd gnd} \
   -left_segment_layer M3 -left_segment_width 5 \
   -right_segment_layer M3 -right_segment_width 5 \
   -bottom_segment_layer MT -bottom_segment_width 5 \
   -top_segment_layer MT -top_segment_width 5

write_floorplan -all ${scripts_path}/floorplan.tcl

save_mw_cel -as ${block_name}_floorplan

###############################################################################
# PLACEMENT
###############################################################################
check_physical_design -stage pre_place_opt

if {[place_opt -area_recovery] == 0} {
   puts "ERROR: Placement Error."
   exit; # Exits ICC if a serious linking problem is encontered
}

derive_pg_connection -power_net {vdd} -ground_net {gnd}
derive_pg_connection -power_net {vdd} -ground_net {gnd} -tie

report_congestion

preroute_standard_cells -connect horizontal  -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}

save_mw_cel -as "${block_name}_placed"

###############################################################################
# CTS
###############################################################################
check_physical_design -stage pre_clock_opt

set_clock_tree_references -reference ${clock_tree_cells}
set_clock_tree_options -layer_list {M1 M2 M3 M4 MT}
clock_opt -area_recovery

derive_pg_connection -power_net {vdd} -ground_net {gnd}
derive_pg_connection -power_net {vdd} -ground_net {gnd} -tie

save_mw_cel -as "${block_name}_postCTS"

###############################################################################
# ROUTING
###############################################################################
check_physical_design -stage pre_route_opt

set_ignored_layers -min_routing_layer M2 -max_routing_layer MT

route_opt -area_recovery

save_mw_cel -as "${block_name}_routed"

###############################################################################
# Timing analysis
###############################################################################
report_case_analysis -nosplit -all > ../../../dgen/pnr/reports/timing_max.rpt
report_timing \
   -nosplit \
   -path_type full \
   -delay_type max \
   -max_paths 10000 \
   -crosstalk_delta \
   -transition_time \
   -capacitance >> ../../../dgen/pnr/reports/timing_max.rpt
report_case_analysis -nosplit -all > ../../../dgen/pnr/reports/timing_min.rpt
report_timing \
   -nosplit \
   -path_type full \
   -delay_type min \
   -max_paths 10000 \
   -crosstalk_delta \
   -transition_time \
   -capacitance >> ../../../dgen/pnr/reports/timing_min.rpt

###############################################################################
# Finish
###############################################################################

# Add fillers
insert_stdcell_filler \
   -cell_with_metal {GAUNUSED096 GAUNUSED048 GAUNUSED024 GAUNUSED012 GAUNUSED006 GAUNUSED003 FILL2 FILL1} \
   -connect_to_power vdd \
   -connect_to_ground gnd

derive_pg_connection -power_net {vdd} -ground_net {gnd}
derive_pg_connection -power_net {vdd} -ground_net {gnd} -tie

insert_zrt_redundant_vias

derive_pg_connection -power_net {vdd} -ground_net {gnd}
derive_pg_connection -power_net {vdd} -ground_net {gnd} -tie

verify_lvs

###############################################################################
# Perform 2.5D extraction
###############################################################################
extract_rc -coupling_cap

###############################################################################
# Save output
###############################################################################
write_def -output ../../../dgen/pnr/def/${block_name}.def
write_verilog -no_physical_only_cells -wire_declaration ../../../dgen/pnr/netlist/${block_name}.v
write_sdf ../../../dgen/pnr/sdf/${block_name}.sdf
write_parasitics -format spef -output "../../../dgen/pnr/spef/parasitics.hier.spef"

save_mw_cel -as "${block_name}_signoff"

set_write_stream_options \
   -child_depth 20 \
   -keep_data_type \
   -flatten_via \
   -output_outdated_fill \
   -output_geometry_property

write_stream -format gds "../../../dgen/pnr/gds/${block_name}.gds"
