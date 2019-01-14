#####################################################################################
#
# Description:
# ------------
#
# Synthesis scripts for Synopsys Design Compiler.
#
#####################################################################################

#################################################################################
# Initialization message
#################################################################################
puts ""
puts ""
puts ""
puts "INFO: Starting synthesis process."

#################################################################################
# Reference paths
#################################################################################
set scripts_path "../../../scripts/syn"

#################################################################################
# Default synthesis options
#################################################################################
# ----- Optimization options -----
set flat_design            "false"
set constraint_design      "true"
set constraints_first      "false"
set remove_assigns         "true"

# ----- Low power options -----
set insert_clk_gating      "true"
set clk_gating_min_num     3
set dynamic_optimization   "false"
set xor_gating             "false"

# ----- DFT options -----
set scan_design            "false"
set scan_chains_num        1
set non_inverting_scan     "false"
set fix_dft_violations     "false"

#################################################################################
# Set system variables
#################################################################################
set access_internal_pins   "true"

#################################################################################
# Defining variables
#################################################################################
set rtl_dir "../../../../rtl"

#################################################################################
# Source script files
#################################################################################
if {[file exists ${scripts_path}/find_files.tcl]} {
   source ${scripts_path}/find_files.tcl
} else {
   puts "ERROR: file 'find_files.tcl' doesn't exist."
}
if {[file exists ${scripts_path}/addons.tcl]} {
   source ${scripts_path}/addons.tcl
} else {
   puts "ERROR: file 'addons.tcl' doesn't exist."
}

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
if {[file exists ${scripts_path}/syn_setup.tcl]} {
   source ${scripts_path}/syn_setup.tcl
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

#############################################################################
# Create list of RTL files
#############################################################################
set rtl_files_v     [find_files ${rtl_dir} "*.v"]
set rtl_files_vhdl  [find_files ${rtl_dir} "*.vhd"]
set rtl_files_sv    [find_files ${rtl_dir} "*.sv"]
set header_files_v  [find_files ${rtl_dir} "*.vh"]
set header_files_sv [find_files ${rtl_dir} "*.svh"]
if {${rtl_files_v}=="" && ${rtl_files_vhdl}==""} {
   puts "ERROR: No RTL files found in source directory."
   puts ""
   puts ""
   puts ""
   exit
}

puts "INFO: RTL file list in source directory"
foreach filename ${rtl_files_v} {
   set filename [split ${filename} "/"]
   set filename [lindex ${filename} end]
   puts "         ${filename}"
}
foreach filename ${rtl_files_vhdl} {
   set filename [split ${filename} "/"]
   set filename [lindex ${filename} end]
   puts "         ${filename}"
}
foreach filename ${rtl_files_sv} {
   set filename [split ${filename} "/"]
   set filename [lindex ${filename} end]
   puts "         ${filename}"
}
foreach filename ${header_files_v} {
   set filename [split ${filename} "/"]
   set filename [lindex ${filename} end]
   puts "         ${filename}"
}
foreach filename ${header_files_sv} {
   set filename [split ${filename} "/"]
   set filename [lindex ${filename} end]
   puts "         ${filename}"
}

###############################################################################
# Library setup
###############################################################################
puts "INFO: Setting up libraries..."
set_app_var       search_path        "${search_paths} ${rtl_dir}"
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
set mw_design_lib ../../../dgen/syn/db/mw/${block_name}

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
define_design_lib WORK -path "./"

###############################################################################
# Read RTL files
###############################################################################
puts "INFO: Reading RTL files..."
if {${rtl_files_v}!=""} {
   analyze -library WORK -format verilog ${rtl_files_v}
}
if {${rtl_files_vhdl}!=""} {
   analyze -library WORK -format vhdl ${rtl_files_vhdl}
}
if {${rtl_files_sv}!=""} {
   analyze -library WORK -format sverilog ${rtl_files_sv}
}

###############################################################################
# Elaborate design
###############################################################################
elaborate ${block_name} -library WORK

###############################################################################
# Set synthesis variables
###############################################################################
set_app_var compile_advanced_fix_multiple_port_nets              "true"
set_app_var compile_delete_unloaded_sequential_cells             "true"
set_app_var compile_enable_register_merging                      "true"
set_app_var compile_enable_register_merging_with_exceptions      "true"
set_app_var compile_enhanced_resource_sharing                    "true"
set_app_var compile_final_drc_fix                                "all"
set_app_var compile_register_replication                         "true"
set_app_var compile_register_replication_across_hierarchy        "true"
set_app_var compile_register_replication_do_size_only            "true"
set_app_var compile_seqmap_propagate_constants                   "true"
set_app_var compile_seqmap_propagate_constants_size_only         "true"
set_app_var hdlin_check_no_latch                                 "true"
set_app_var hdlin_ff_always_async_set_reset                      "true"
set_app_var verilogout_no_tri                                    "true"
set_app_var verilogout_equation                                  "false"
set_fix_multiple_port_nets -all -buffer_constants

###############################################################################
# Checking design integrity
###############################################################################
if {[link]==0} {
   puts "ERROR: Linking error. Aborting synthesis..."
   puts ""
   puts ""
   puts ""
   exit
}
if {[check_design]==0} {
   puts "ERROR: Check design error. Aborting synthesis..."
   puts ""
   puts ""
   puts ""
   exit
}
puts ""

###############################################################################
# Uniquify instances
###############################################################################
uniquify

###############################################################################
# Listing libraries
###############################################################################
puts "INFO: Listing used libraries."
list_libs
puts ""

###############################################################################
# Save generic netlist
###############################################################################
write -hierarchy -format ddc     -output "../../../dgen/syn/db/generic/${block_name}.ddc"
write -hierarchy -format verilog -output "../../../dgen/syn/netlist/${block_name}.generic.v"
puts ""

###############################################################################
# Apply constraints
###############################################################################
if {${scan_design}} {
   if {[file exists ${scripts_path}/dft_constraints.tcl]} {
      source ${scripts_path}/dft_constraints.tcl
      puts "INFO: 'dft_constraints.tcl' file sourced."
   } else {
      puts "ERROR: 'dft_constraints.tcl' file doesn't exist."
   }
   if {[input_exists ${scan_shift_signal}]} {
      set_case_analysis 0 ${scan_shift_signal}
   }
   if {[input_exists ${scan_mode_signal}]} {
      set_case_analysis 0 ${scan_mode_signal}
   }
}
if {${constraint_design}} {
   set_max_area 0
   if {[file exists ${scripts_path}/constraints.tcl]} {
      source ${scripts_path}/constraints.tcl
      puts "INFO: 'constraints.tcl' file sourced."
   } else {
      puts "ERROR: file 'constraints.tcl' doesn't exist."
   }
   report_port -verbose > ../../../dgen/syn/reports/ports_constraints.rpt
   report_clock [all_clocks] > ../../../dgen/syn/reports/clocks_constraints.rpt
   check_timing > ../../../dgen/syn/reports/check_timing.rpt
   report_constraint -verbose > ../../../dgen/syn/reports/constraints.rpt
   report_constraint -verbose -all_violators > ../../../dgen/syn/reports/constraints_violators.rpt
} else {
   puts "INFO: The design will be sinthesized for minimum area only."
   puts "      Timing constraints will not be taken into account!!!"
   remove_constraint -all
   remove_clock -all
   set_max_area 0
}

###############################################################################
# Change constraints priority
###############################################################################
if {${constraints_first}} {
   set_cost_priority -delay
} else {
   set_cost_priority -design_rules
}

###############################################################################
# Flat design
###############################################################################
if {${flat_design}} {
   ungroup -flatten -all -all_instances
}

###############################################################################
# Enable gating clock
###############################################################################
if {${dynamic_optimization}} {
   set_dynamic_optimization   "true"
} else {
   set_dynamic_optimization   "false"
}

###############################################################################
# Remove assigns
###############################################################################
if {${remove_assigns}} {
   set_fix_multiple_port_nets -feedthroughs -outputs -buffer_constants
}

###############################################################################
# Operating conditions and analysis type
###############################################################################
set_operating_conditions \
   -analysis_type bc_wc \
   -max ${max_oper_cond} -min ${min_oper_cond}

###############################################################################
# Synthesize design
###############################################################################
puts "INFO: Checking design integrity..."
compile_ultra -check_only > ../../../dgen/syn/reports/check_design.rpt
puts "INFO: Compiling design ${current_design}"
if {!${flat_design}} {
   compile_ultra -no_autoungroup
} else {
   compile_ultra
}

###############################################################################
# Insert clock gating
###############################################################################
if {!${scan_design}} {
   if {${insert_clk_gating}} {
      if {!${exists_clk_gating_cells}} {
         set_clock_gating_style -control_point before
      }
      if {!${flat_design}} {
         if {${xor_gating}} {
            compile_ultra -no_autoung -incremental -gate_clock -self_gating
         } else {
            compile_ultra -no_autoung -incremental -gate_clock
         }
      } else {
         if {${xor_gating}} {
            compile_ultra -incremental -gate_clock -self_gating
         } else {
            compile_ultra -incremental -gate_clock
         }
      }
   }
}

###############################################################################
# DFT
###############################################################################
if {${scan_design}} {
   if {![input_exists ${scan_in_signal}]} {
      create_port -direction "in" ${scan_in_signal}
      puts "INFO: Input port '${scan_in_signal}' created."
   }
   if {![input_exists ${scan_shift_signal}]} {
      create_port -direction "in" ${scan_shift_signal}
      puts "INFO: Input port '${scan_shift_signal}' created."
   }
   if {![output_exists ${scan_out_signal}]} {
      create_port -direction "out" ${scan_out_signal}
      puts "INFO: Input port '${scan_out_signal}' created."
   }

   if {${fix_dft_violations}} {
      set_dft_configuration \
         -scan                   enable \
         -fix_clock              enable \
         -fix_set                enable \
         -fix_reset              enable \
         -connect_clock_gating   enable
   } else {
      set_dft_configuration \
         -scan                   enable  \
         -fix_clock              disable \
         -fix_set                disable \
         -fix_reset              disable \
         -connect_clock_gating   enable
   }
   set compile_seqmap_identify_shift_registers "true"
   set compile_seqmap_identify_shift_registers_with_synchronous_logic "true"

   set_scan_configuration -style multiplexed_flip_flop -chain_count ${scan_chains_num}

   set_dft_signal -type ScanDataIn  -view spec -port ${scan_in_signal}
   set_dft_signal -type ScanEnable  -view spec -port ${scan_shift_signal} -usage {scan clock_gating}
   set_dft_signal -type ScanDataOut -view spec -port ${scan_out_signal}

   create_test_protocol -infer_async -infer_clock
   dft_drc -verbose  > ../../../dgen/syn/reports/dft_drc_prev.rpt
   preview_dft -verbose > ../../../dgen/syn/reports/dft_preview.rpt

   if {${insert_clk_gating}} {
      if {!${exists_clk_gating_cells}} {
         set_clock_gating_style -control_point before -control_signal ${scan_shift_signal}
      }
      if {!${flat_design}} {
         if {${xor_gating}} {
            compile_ultra -no_autoung -incremental -gate_clock -self_gating -scan
         } else {
            compile_ultra -no_autoung -incremental -gate_clock -scan
         }
      } else {
         if {${xor_gating}} {
            compile_ultra -incremental -gate_clock -self_gating -scan
         } else {
            compile_ultra -incremental -gate_clock -scan
         }
      }
   }
   insert_dft
   dft_drc -verbose  > ../../../dgen/syn/reports/dft_drc_post.rpt
}

#################################################################################
# Bit blast busses
#################################################################################
if {${bit_blasting}} {
   define_name_rules bit_blast_busses \
      -remove_internal_net_bus \
      -remove_port_bus \
      -remove_irregular_port_bus \
      -remove_irregular_net_bus
   change_names -hierarchy -rules bit_blast_busses
   set_app_var verilogout_single_bit "true"
}

###############################################################################
# Remove all unconnected ports
###############################################################################
remove_unconnected_ports [find -hierarchy cell "*"]

###############################################################################
# Parasitics extraction
###############################################################################
set_extraction_options \
   -max_process_scale 1.0 \
   -min_process_scale 1.0 \
   -reference_direction use_from_tluplus
extract_rc -estimate

###############################################################################
# Timing analysis
###############################################################################
report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_max.rpt
report_timing \
   -nosplit \
   -path_type full \
   -delay_type max \
   -max_paths 10000 \
   -crosstalk_delta \
   -transition_time \
   -capacitance >> ../../../dgen/syn/reports/timing_max.rpt
report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_min.rpt
report_timing \
   -nosplit \
   -path_type full \
   -delay_type min \
   -max_paths 10000 \
   -crosstalk_delta \
   -transition_time \
   -capacitance >> ../../../dgen/syn/reports/timing_min.rpt

report_timing -loops  > ../../../dgen/syn/reports/loops.rpt

if {${scan_design}} {
   if {[input_exists ${scan_shift_signal}]} {
      set_case_analysis 0 ${scan_shift_signal}
   }
   if {[input_exists ${scan_mode_signal}]} {
      set_case_analysis 1 ${scan_mode_signal}
   }
   report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_max_sm_1_se_0.rpt
   report_timing \
      -nosplit \
      -path_type full \
      -delay_type max \
      -max_paths 10000 \
      -crosstalk_delta \
      -transition_time \
      -capacitance >> ../../../dgen/syn/reports/timing_max_sm_1_se_0.rpt
   report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_min_sm_1_se_0.rpt
   report_timing \
      -nosplit \
      -path_type full \
      -delay_type min \
      -max_paths 10000 \
      -crosstalk_delta \
      -transition_time \
      -capacitance >> ../../../dgen/syn/reports/timing_min_sm_1_se_0.rpt
   if {[input_exists ${scan_shift_signal}]} {
      set_case_analysis 1 ${scan_shift_signal}
   }
   if {[input_exists ${scan_mode_signal}]} {
      set_case_analysis 1 ${scan_mode_signal}
   }
   report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_max_sm_1_se_1.rpt
   report_timing \
      -nosplit \
      -path_type full \
      -delay_type max \
      -max_paths 10000 \
      -crosstalk_delta \
      -transition_time \
      -capacitance >> ../../../dgen/syn/reports/timing_max_sm_1_se_1.rpt
   report_case_analysis -nosplit -all > ../../../dgen/syn/reports/timing_min_sm_1_se_1.rpt
   report_timing \
      -nosplit \
      -path_type full \
      -delay_type min \
      -max_paths 10000 \
      -crosstalk_delta \
      -transition_time \
      -capacitance >> ../../../dgen/syn/reports/timing_min_sm_1_se_1.rpt
   if {[input_exists ${scan_shift_signal}]} {
      set_case_analysis 0 ${scan_shift_signal}
   }
   if {[input_exists ${scan_mode_signal}]} {
      set_case_analysis 0 ${scan_mode_signal}
   }
}

# ###############################################################################
# # Generate additional reports
# ###############################################################################
puts "INFO: Generating reports..."
report_annotated_check -nosplit > ../../../dgen/syn/reports/annotated_checks.rpt
report_annotated_delay -nosplit > ../../../dgen/syn/reports/annotated_max_delays.rpt
report_annotated_delay -nosplit -min > ../../../dgen/syn/reports/annotated_min_delays.rpt
report_annotated_transition -nosplit > ../../../dgen/syn/reports/annotated_transitions.rpt
report_area -nosplit -physical > ../../../dgen/syn/reports/area_physical.rpt
report_area -nosplit -hierarchy > ../../../dgen/syn/reports/area_hierarchy.rpt
report_area -nosplit -designware > ../../../dgen/syn/reports/area_designware.rpt
report_clock_gating -nosplit -verbose -gated -ungated > ../../../dgen/syn/reports/clock_gating.rpt
report_self_gating -nosplit -ungated > ../../../dgen/syn/reports/xor_gating.rpt
report_clock_gating_check -nosplit > ../../../dgen/syn/reports/clock_gating_checks.rpt
report_clock_timing -nosplit -verbose -clock [all_clocks] -type latency > ../../../dgen/syn/reports/clock_latency.rpt
report_clock_timing -nosplit -verbose -clock [all_clocks] -type skew > ../../../dgen/syn/reports/clock_skew.rpt
report_clock_tree -nosplit > ../../../dgen/syn/reports/clock_trees.rpt
report_design -nosplit > ../../../dgen/syn/reports/design.rpt
report_fsm -nosplit > ../../../dgen/syn/reports/fsm.rpt
report_hierarchy -nosplit -full > ../../../dgen/syn/reports/hierarchy.rpt
report_port -nosplit -verbose > ../../../dgen/syn/reports/ports.rpt
report_power -nosplit -hierarchy -verbose -analysis_effort medium > ../../../dgen/syn/reports/power.rpt
report_qor > ../../../dgen/syn/reports/qor.rpt
report_latch_loop_groups -nosplit > ../../../dgen/syn/reports/latch_loop_groups.rpt
report_test_point_configuration > ../../../dgen/syn/reports/test_point_config.rpt
report_test_point_element > ../../../dgen/syn/reports/test_point_element.rpt
report_testability_configuration > ../../../dgen/syn/reports/testability_config.rpt
report_timing_derate -nosplit -include_inherited > ../../../dgen/syn/reports/tming_derate.rpt

if {${scan_design}} {
   report_dft_clock_controller -view spec > ../../../dgen/syn/reports/dft_clock_controller.rpt
   report_dft_clock_gating_configuration > ../../../dgen/syn/reports/dft_clock_gating_config.rpt
   report_dft_clock_gating_pin > ../../../dgen/syn/reports/dft_clock_gating_pin.rpt
   report_dft_configuration > ../../../dgen/syn/reports/dft_config.rpt
   report_dft_connect > ../../../dgen/syn/reports/dft_connect.rpt
   report_dft_equivalent_signals > ../../../dgen/syn/reports/dft_equivalent_signals.rpt
   report_dft_insertion_configuration  > ../../../dgen/syn/reports/dft_insertion_config.rpt
   report_dft_signal -view spec -test_mode all > ../../../dgen/syn/reports/dft_signal.rpt
   report_scan_chain > ../../../dgen/syn/reports/scan_chain.rpt
   report_scan_configuration -test_mode all > ../../../dgen/syn/reports/scan_chain_config.rpt
}

###############################################################################
# Write final database
###############################################################################
write -hierarchy -format ddc -output "../../../dgen/syn/db/mapped/${block_name}.ddc"

###############################################################################
# Write final milkyway database
###############################################################################
set milkyway_design_library ../../../dgen/syn/db/mw/
write_milkyway -overwrite -output ${block_name}.mw

###############################################################################
# Write Verilog netlist
###############################################################################
write -hierarchy -format verilog -output "../../../dgen/syn/netlist/${block_name}.mapped.v"

###############################################################################
# Write SDC for P&R
###############################################################################
set_propagated_clock [all_clocks]
write_sdc ../../../dgen/syn/sdc/constraints.sdc

###############################################################################
# Start GUI
###############################################################################
gui_start

###############################################################################
# Finishing synthesis
###############################################################################
puts ""
puts ""
puts "INFO: Synthesis process done!!!"
puts ""
puts "INFO: Type \"quit!\" for leaving the current session."
puts ""
puts ""
puts ""
