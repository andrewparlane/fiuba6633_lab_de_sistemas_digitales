#####################################################################################
#
# Description:
# ------------
#
# Synthesis configuration scripts for Synopsys Design Compiler.
#
#
#   Variables description:
#
#   ----- Optimization options -----
#   - flat_design           : Makes the design flat, destroying all hierarchies.
#   - constraint_design     : Has into account design constraints.
#   - constraints_first     : Constraints are met before fixing DRC rules.
#   - remove_assigns        : Aliased ports are replaced by means of buffer insertion.
#
#  ----- Low power options -----
#  - insert_clk_gating      : Inserts clock gating logic.
#  - clk_gating_min_num     : Minimum number of registers grouped by the same ICG cell.
#  - dynamic_optimization   : Allows boolean optimization for dynamic power reduction.
#  - xor_gating             : Allows insert XOR-gating.
#
#  ----- DFT options -----
#  - scan_design            : Inserts scan chain logic.
#  - scan_chains_num        : Number of scan chains to insert.
#  - non_inverting_scan     : Avoid using QN output of DFF in scan propagation.
#  - fix_dft_violations     : Fixes DFT violations (clocks dividers, active resets, etc.).
#
#####################################################################################

#####################################################################################
# Edit synthesis options
#####################################################################################

set block_name             "micro"

# ----- Optimization options -----
set flat_design            "false"
set constraint_design      "true"
set constraints_first      "false"
set remove_assigns         "true"
set bit_blasting           "false"

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
set insert_test_points     "false"
