# -------------------------------------
# Process libs
# -------------------------------------
set search_paths             "/usr/pdks/IBM_7RF/kit/digital/std_cells/liberty/bc /usr/pdks/IBM_7RF/kit/digital/std_cells/liberty/nom /usr/pdks/IBM_7RF/kit/digital/std_cells/liberty/wc /usr/pdks/IBM_7RF/kit/digital/ext_cells/liberty/bc /usr/pdks/IBM_7RF/kit/digital/ext_cells/liberty/nom /usr/pdks/IBM_7RF/kit/digital/ext_cells/liberty/wc /usr/pdks/IBM_7RF/kit/digital/std_cells/verilog /usr/pdks/IBM_7RF/kit/digital/ext_cells/verilog"
set target_max_libs          "PwcV162T125_STD_CELL_7RF.db PwcV162T125_EXT_CELLS_7RF.db"
set target_min_libs          "PbcV198Tm55_STD_CELL_7RF.db PbcV198Tm55_EXT_CELLS_7RF.db"
set verilog_stdcell_models   "ibm_cmrf7sf_std_cells.v ibm_cmrf7sf_ext_cells.v"
set milkyway_ref_lib         "/usr/pdks/IBM_7RF/kit/digital/std_cells/milkyway/std_cells_7rf_6AM.mw /usr/pdks/IBM_7RF/kit/digital/ext_cells/milkyway/ext_cells_7rf.mw"
set tlup_max_file            "/usr/pdks/IBM_7RF/synopsys/astro_tlu/tluplus/cmos7rf_6AM_FuncCmax.tluplus"
set tlup_min_file            "/usr/pdks/IBM_7RF/synopsys/astro_tlu/tluplus/cmos7rf_6AM_FuncCmin.tluplus"
set tlup_typ_file            "/usr/pdks/IBM_7RF/synopsys/astro_tlu/tluplus/cmos7rf_6AM_nm.tluplus"
set tech2itf_file            "/usr/pdks/IBM_7RF/synopsys/astro_tlu/tluplus/cmos7rf_6AM.icc_maskname.map"
set mw_techfile              "/usr/pdks/IBM_7RF/synopsys/techfiles/milkyway/techfile6AM.mw.tf"
# -------------------------------------

# -------------------------------------
# Synopsys specific libs
# -------------------------------------
set synopsys_libs_path       "/usr/synopsys/J-2014.09-SP5-3/design_compiler/libraries/syn"
set dw_foundation_lib        "${synopsys_libs_path}/dw_foundation.sldb"
set generic_lib              "${synopsys_libs_path}/generic.sdb"
# -------------------------------------

# -------------------------------------
# Operating conditions
# -------------------------------------
set max_oper_cond             "PwcV162T125_STD_CELL_7RF"
set min_oper_cond             "PbcV198Tm55_STD_CELL_7RF"
# -------------------------------------

# -------------------------------------
# Clock gating cells in tech library
# -------------------------------------
set exists_clk_gating_cells  "false"
# -------------------------------------

# -------------------------------------
# Clock tree cells
# -------------------------------------
set clock_tree_cells {CLK_I CLK_K CLK_M CLK_O CLK_Q CLKI_I CLKI_K CLKI_M CLKI_O CLKI_Q}
# -------------------------------------

puts "INFO: digtech_settings.tcl sourced."
