# ----------------------------------------------------------------------------------
# Requirements:
#	QuestaSim - We use vcom and vsim.
#	Each test bench must contain an instantiation called dut.
#	Each test bench must call std.env.stop when it's finished testing.
# ----------------------------------------------------------------------------------

ifndef WLF
# set the default target to be all. Otherwise it's the first target it finds
.DEFAULT_GOAL := all
else
.DEFAULT_GOAL := view
endif

# Directories
SIM_DIR			= sim
WAVES_DIR		= $(SIM_DIR)/waves
SRC_DIR			= src
PKG_DIR			= $(SRC_DIR)/pkg
TB_SRC_DIR		= $(SRC_DIR)/tb

# src files
SRCS	= $(wildcard $(PKG_DIR)/*.sv) \
		  $(wildcard $(SRC_DIR)/*.sv)

# tb files
TB_SRCS	= $(wildcard $(TB_SRC_DIR)/*.sv)

# Extra arguments beyond the defaults in helper.mk
VCOM_FLAGS		=
VSIM_FLAGS		=

# Now include our helper.mk which has all the rules we need
# to create our library, compile and simulate our test benches
include ../helper/helper.mk

# default rule is to create the library, and compile all the components
all: srcs tb_srcs

.PHONY: common all

# tests
alu: all
	@$(call VSIM_CMD, alu_tb)

reset_sync: all
	@$(call VSIM_CMD, reset_sync_tb)

mult_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=mult_test -gROM_FILE_PATH=tests/mult_test.dat)

nand_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=nand_test -gROM_FILE_PATH=tests/nand_test.dat)

xor_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=xor_test -gROM_FILE_PATH=tests/xor_test.dat)

nor_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=nor_test -gROM_FILE_PATH=tests/nor_test.dat)

xnor_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=xnor_test -gROM_FILE_PATH=tests/xnor_test.dat)

add_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=add_test -gROM_FILE_PATH=tests/add_test.dat)

sub_test: all
	@$(call VSIM_CMD, tp1_tb, -gTEST_NAME=sub_test -gROM_FILE_PATH=tests/sub_test.dat)

all_tests: mult_test nand_test xor_test xnor_test nor_test add_test sub_test

.PHONY: alu reset_sync mult_test nand_test xor_test xnor_test nor_test add_test sub_test all_tests

# delete the library and all compiled files
clean: helper_clean
	$(call DEL_VLIB_CMD, $(COMMON_LIB))

distclean: clean
	make -C $(COMMON_DIR) clean

.PHONY: clean distclean
