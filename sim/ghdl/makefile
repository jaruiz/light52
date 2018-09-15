#-------------------------------------------------------------------------------
# Light52 test driver makefile.
# Builds and runs test code on GHDL (mcode backend only!).
#
# You need to have GHDL on your PATH and it needs to be the 'mcode backend'
# version of GHDL. Build instructions here:
# https://ghdl.readthedocs.io/en/latest/building/mcode/GNULinux-GNAT.html
#
#
# QUICK START
# ~~~~~~~~~~~
# Run this:
# 		make all TEST=cpu_test
# You'll see the console output of the CPU tester program run on both RTL 
# simulator and ISS, and a success message when the execution logs are matched.
#
#
# TARGETS and their dependencies
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
# sw: 
#	Build 8051 test program by invoking its makefile with target 'all'.
#	Will produce test object code in the test directory including a vhdl 
#	package with the code ROM initialization data. 
# rtl: sw
#	Run test program on GHDL.
#	No support for other simulators but you should be able to fix that in a 
#	jiffie.
# iss: sw
#	Run test program on b51 ISS.
#	Uses b51 ISS supplies with this project and assumes the executable has been
#	built -- do that yourself beforehand.
# all: rtl iss
#	Runs test program on both RTL simulator and ISS and compares the resulting 
#	execution log -- essentially using the ISS as a golden model.
#
# CONFIGURATION
# ~~~~~~~~~~~~~
# You can select and configure the test you want to run by setting these macros
# via the command line:
#
# TEST=name
# 	Name of the 8051 test program to be run. 
# 	Must be a subdirectory within '../../test' with a suitable makefile -- see 
# 	supplied tests.
# 	By default this is 'cpu_test', the basic opcode tester.
# 
# BCD={0|1}
# 	If 0, the CPU will be configured without the optional BCD instructions.
# 	If 1, the optional BCD instructions will be built in.
# 	By default this is 1.
# 	This macro will be passed on to the SW test build makefile.
#
#   HOWEVER, there's no easy way to pass that info to ghdl so currently
#   all tests run with BCD instructions implemented. 
#   If you want to test the CPU with BCD instructions disabled you need to 
#   manually hack the TB entity generic...
# 
#-------------------------------------------------------------------------------

SHELL := /bin/bash

.DEFAULT: help
.PHONY: help
help:
	@echo "(Please read the usage instructions in the makefile comments.)"

#---- Project config. ----------------------------------------------------------

PROJECTDIR	 	:= ../..
SWDIR 			:= $(PROJECTDIR)/test
RTLDIR 			:= $(PROJECTDIR)/vhdl
TBDIR  			:= $(RTLDIR)/tb

CC_HIGLIGHT 	= "\033[1;34m"
CC_NORMAL 		= "\033[0m"

#---- Simulator configuration. -------------------------------------------------

# GHDL.
GHDLC			:= ghdl
GHDLFLAGS 		:= -Wno-library
GHDLSIMFLAGS 	:= --ieee-asserts=disable
# GtkWave.
WAVE 			:= gtkwave
# B51
B51 			:= $(PROJECTDIR)/tools/b51/bin/b51


#---- Defaults. ----------------------------------------------------------------

# By default the SW test we'll run is the CPU diagnostic.
TEST ?= cpu_test
# By default we build BCD support on the RTL; the SW will be aware of it.
BCD ?= 1

#---- Sources. -----------------------------------------------------------------

# VHDL package that contains the SW code.
# TODO dependency with SW makefile here, in name of package! 
PKGCODE 		:= ${SWDIR}/${TEST}/obj_code_pkg.vhdl

# Synthesizable RTL sources.
PKGRTL			:= $(RTLDIR)/light52_pkg.vhdl $(RTLDIR)/light52_ucode_pkg.vhdl 
# Order matters.
SRCRTL := \
	$(RTLDIR)/light52_pkg.vhdl \
	$(RTLDIR)/light52_ucode_pkg.vhdl \
	$(RTLDIR)/light52_muldiv.vhdl \
	$(RTLDIR)/light52_alu.vhdl \
	$(RTLDIR)/light52_cpu.vhdl \
	$(RTLDIR)/light52_timer.vhdl \
	$(RTLDIR)/light52_uart.vhdl \
	${PKGCODE} \
	$(RTLDIR)/light52_mcu.vhdl


# RTL TB sources.
PKGTB  			:= $(TBDIR)/txt_util.vhdl $(TBDIR)/light52_tb_pkg.vhdl
SRCTB 			:= $(TBDIR)/light52_tb.vhdl
TBUNIT			:= light52_tb


#---- Rules -- Test SW build ---------------------------------------------------

# Make sure the test SW directory at least exists.
.PHONY: check_test
check_test:
ifeq ($(wildcard $(SWDIR)/$(TEST)/.),)
	$(error ERROR: Could not find test directory '$(SWDIR)/$(TEST)'.)
endif

# Build SW, generate ROM files (obj code vhdl package) for RTL simulation.
.PHONY: sw
sw: check_test
	make -C $(SWDIR)/$(TEST) package BCD=$(BCD)



#-- Rules -- ISS simulaton on b51 ----------------------------------------------

# Run test code on ISS.
.PHONY: iss
iss: sw
	@echo -e $(CC_HIGLIGHT)"Running '"$(TEST)"' on b51..."$(CC_NORMAL)
	$(B51) --bcd $(SWDIR)/$(TEST)/bin/software.hex

.PHONY: debug
debug: sw
	@echo -e $(CC_HIGLIGHT)"Running '"$(TEST)"' on b51 in debug target mode..."$(CC_NORMAL)
	$(B51) --tty=/dev/pts/9 --bcd $(SWDIR)/$(TEST)/bin/software.hex

#-- Rules -- RTL simulation on ghdl --------------------------------------------

# Just invoke the simulator.
.PHONY: rtl
rtl: sw ghdl 

# Run SW on VHDL TB on GHDL (mcode backend).
.PHONY: ghdl
ghdl: ghdl_rtl 
	@echo -e $(CC_HIGLIGHT)"Running '"$(TEST)"' on ghdl..."$(CC_NORMAL)
	$(GHDLC) -a $(GHDLFLAGS) $(PKGTB) $(SRCTB)
	$(GHDLC) -m $(GHDLFLAGS) $(TBUNIT)
	-$(GHDLC) -r light52_tb $(GHDLSIMFLAGS) --wave=$(TBUNIT).ghw

# Compile the whole set of sources, packages first.
# Note we insert the SW object code package after the main package sources.
.PHONY: ghdl_rtl
ghdl_rtl: $(PKGRTL) $(SRCRTL)
	$(GHDLC) -a $(GHDLFLAGS) ${PKGRTL} ${SRCRTL}

# Invoke ghdl to check source syntax.
.PHONY: ghdl_syntax
ghdl_syntax:
	$(GHDLC) -s $(PKGTB) $(SRCTB)

# Invoke the wave viewer, assume there are waves to view at all.
.PHONY: ghdl_view
ghdl_view : ghdl
	$(WAVE) $(TBUNIT).ghw



#-- Rules -- RTL against ISS ---------------------------------------------------

.PHONY: all
all: iss rtl
	@cmp -s sw_log.txt hw_sim_log.txt; \
	RETVAL=$$?; \
	if [ $$RETVAL -eq 0 ]; then \
		echo -e "\n\033[1;32mEXECUTION LOGS MATCH\033[0m\n"; \
	else \
		echo -e "\n\033[1;31mEXECUTION LOGS DO NOT MATCH\033[0m\n"; \
	fi


#-------------------------------------------------------------------------------

.PHONY: clean
clean: check_test
	-rm -rf *.lst *.map *.rel *.sym *.p *.ihx *.vhdl *.v *.lst
	$(GHDLC) --clean
	-rm -rf *.vcd *.ghw *.cf
	make -C $(SWDIR)/$(TEST) clean
