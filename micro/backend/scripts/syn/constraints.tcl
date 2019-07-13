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

set period 11.0
create_clock -name _iClk -period ${period} [get_ports _iClk]

set_false_path -from [get_ports _iReset]

# data changes 8.9ns after addr changes.
# writes finish 8.9ns after Write asserted.
set ramDelay 8.9

# This means there is $period - $ramDelay free.
# In that time we have to:
#  1) get the output signals from the FF to the port of our core.
#  2) get the output signals from the port of our core to the RAM.
#  3) get the input data from the RAM to the port of our core.
#  4) get the input data from the port of our core to the FF (including setup)
# I'm assuming that 2) and 3) are 0ns in my case. I probably should account
# for these, but without knowing if the SRAM is off / on chip, it's hard to
# guess.
# I'm therefore splitting the available time between 1) and 4).
# 1) gets outputSharePercent
set extra [expr {${period} - ${ramDelay}}]
set outputSharePercent 0.7
set outputShare [expr {${extra} * ${outputSharePercent}}]

# First we must ensure that the outputs get out of our core in a timely
# fashion. If we specify that there's an output delay of ${period} - 
# ${outputShare} then the tools have to find a path that takes only
# ${outputShare} or less to go from the register to the port.
set outputDelay [expr {${period} - ${outputShare}}]

set_output_delay -clock [get_clock _iClk] ${outputDelay} [get_ports _oInstMemAddr]
set_output_delay -clock [get_clock _iClk] ${outputDelay} [get_ports _oDataMemAddr]
set_output_delay -clock [get_clock _iClk] ${outputDelay} [get_ports _oDataMemWData]
set_output_delay -clock [get_clock _iClk] ${outputDelay} [get_ports _oDataMemWrite]

# Next We then set an input delay on the Data inputs.
# This is the delay from the Addr register to the RAM
# and the $ramDelay it takes the data to go valid.
# This means our core has to get the input data from the port
# to the input FF in $period - $inputDelay
# (including the setup time of the FF).
set inputDelay [expr {${outputShare} + ${ramDelay}}]

set_input_delay -clock [get_clock _iClk] ${inputDelay} [get_ports _iInstMemData]
set_input_delay -clock [get_clock _iClk] ${inputDelay} [get_ports _iDataMemRData]

