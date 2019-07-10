#####################################################################################
#
# Description:
# ------------
#
# SDC contraints.
#
#####################################################################################

#####################################################################################
# SDC sintax examples
#####################################################################################
#
# Clock inputs:
# -------------
# create_clock -name <clk_logic_name> -period <period_ns> -waveform {time_rise time_fall} [get_ports <input_port_name>]
# set_clock_transition <transition_time_ns> -rise [get_clocks <clk_logic_name>]
# set_clock_transition <transition_time_ns> -fall [get_clocks <clk_logic_name>]
# set_clock_uncertainty <uncertainty_time_ns> -setup [get_clocks <clk_logic_name>]
# set_clock_uncertainty <uncertainty_time_ns> -hold [get_clocks <clk_logic_name>]
#
#
# Internal generated clocks:
# --------------------------
# create_generated_clock -name <clk_logic_name> -divide_by <integer_number> [get_pins <seq_instance_output_pin>]
#
#
# Async reset inputs:
# -------------------
# Note: It is expected that reset input is synchronized for releasing condition.
# set_false_path -from [get_ports <input_async_reset_port>]
#
#
# Sync inputs:
# ------------
# set_input_delay -clock <clk_logic_name> -max <input_delay_ns> -min <input_delay_ns> [get_ports <input_port_name>]
#
#
# Sync outputs:
# -------------
# set_output_delay -max <input_delay_ns> -min <input_delay_ns> [get_ports <output_port_name>]
#
#
# Async inputs:
# ------------
# set_false_path -from [get_ports <input_port>]
#
#
# Async outputs:
# -------------
# Note: Do nothing, do not constraint at all!!"
#
#
# Internal false paths:
# ---------------------
# set_false_path -from <instance_output_pin> -to <instance_input_pin>
#
#
# Internal multicycle paths:
# --------------------------
# set_multicycle_path <integer_number> -setup -from [get_pins <seq_instance_output_pin>] -to [get_pins <seq_instance_input_pin>]
# set_multicycle_path <integer_number> -hold -from [get_pins <seq_instance_output_pin>] -to [get_pins <seq_instance_input_pin>]
#
#
# Max delays (only make sens if it is less than clock period):
# ------------------------------------------------------------
# set_max_delay -from [get_pins <instance_output_pin>] -to [get_pins <instance_input_pin>]
#
#
# Min delays (only make sens if it is less than clock period):
# ------------------------------------------------------------
# set_min_delay -from [get_pins <instance_output_pin>] -to [get_pins <instance_input_pin>]
#
#
# Case analysis:
# --------------
# set_case_analysis <0|1> [get_ports <input_port_name>]
# set_case_analysis <0|1> [get_pints <instance_pin_name>]
#
#
# Electrical conditions:
# ----------------------
# set_driving_cell -lib_cell <lib_cell_name> -library <library_name> [all_inputs]
# set_load <capacitance_pf> [all_outputs]
#
#
#####################################################################################
# Edit synthesis contraints here!!!
#####################################################################################

create_clock -name _iClk -period 10 [get_ports _iClk]

set_false_path -from [get_ports _iReset]

set_input_delay -clock [get_clock _iClk] -max 8.9 [get_ports _iInstMemData]
set_input_delay -clock [get_clock _iClk] -max 8.9 [get_ports _iDataMemRData]


