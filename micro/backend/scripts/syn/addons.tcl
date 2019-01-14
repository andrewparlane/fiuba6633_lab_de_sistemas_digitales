#####################################################################################
#
# Description:
# ------------
#
# Functions to add some functionality to Design Compiler Synopsys tool.
#
#####################################################################################

puts "INFO: dcompiler_addons.tcl sourced."

#####################################################################################
proc input_exists {input_port_name} {
   set in_port_list  [get_object_name [all_inputs]]
   if {[expr [lsearch -exact ${in_port_list} ${input_port_name}]+1]} {
      return "true"
   } else {
      return "false"
   }
 }
#####################################################################################

#####################################################################################
proc output_exists {output_port_name} {
   set out_port_list  [get_object_name [all_outputs]]
   if {[expr [lsearch -exact ${out_port_list} ${output_port_name}]+1]} {
      return "true"
   } else {
      return "false"
   }
 }
#####################################################################################
