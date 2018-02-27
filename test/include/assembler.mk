#-- assembler.mk - Makefile include common to all assembly source tests --------
#
# This make include file should be included in a project makefile *after* the 
# project configuration variables have been defined. See the hello_asm makefile 
# for an usage example.

# (C source tests use common makefile 'common.mk' and not this one.)


#-- Build CPU test program and create VHDL package with object code ------------

# In project light52 I chose to use ASEM51 for assembly-only programs instead of
# ASxxxx, which is included with SDCC. Maybe a mistake, in hindsight.
# (Please note that ASEM51 can only deal with single-source programs.) so this 

# Check the program config variables we need.
ifeq ($(TEST),)
$(error Missing configuration variable TEST)
endif
ifeq ($(SRCFILE),)
$(error Missing configuration variable SRCFILE)
endif
ifeq ($(XCODE_SIZE),)
$(error Missing configuration variable XCODE_SIZE)
endif
ifeq ($(XDATA_SIZE),)
$(error Missing configuration variable XDATA_SIZE)
endif

# By default, we build for real HW UART (not TB simulated UART).
ifeq ($(SIMULATED_UART),1)
UART_FLAG = --define=SIMULATED_UART
else
UART_FLAG =
endif


ifeq ($(BCD),1)
	BCD_FLAG = --define=BCD
else
	BCD =
endif

#-- Toolchain executables ------------------------------------------------------

# This program uses the ASEM51 syntax as opposed to SDCC's used in other tests.
# You'll need to point this at your ASEM51 install.
AS = ../../../../../tools/asem51/asem
RM = rm
CP = cp

#-- Project directories, default assembler flags... ----------------------------

# Script used to build vhdl package out of Intel hex file.
BRPATH = ../../tools/build_rom
# Dir where vhdl package will end -- where the sim makefile expects it.
VHDL_TB_PATH = .

ifndef AFLAGS
AFLAGS = --includes=../include $(BCD_FLAG) $(UART_FLAG)
endif


#-- Targets & rules ------------------------------------------------------------

# Try to mitigate the fact that we're depending on a piece of SW most folks will
# have to install for this test only...
ASEM51_PRESENT := $(shell command -v ${AS} 2> /dev/null)
find_asem51:
ifeq ($(ASEM51_PRESENT),)
	$(error ASEM51 not found -- see README file)
else
endif

.PHONY: hexfile
hexfile: find_asem51
	@echo $(ASEM51_PRESENT)
	$(AS) src/$(SRCFILE).a51 bin/software.hex lst/$(SRCFILE).lst $(AFLAGS)

# Root target, invoked by sim makefile.
.PHONY: all
all: package
	@echo Done


#-- Targets that build the synthesizable vhdl ----------------------------------

#-- Create VHDL package with object code and synthesis parameters.
.PHONY: package
package: hexfile
	@echo Building object code VHDL package...
	@python $(BRPATH)/src/build_rom.py \
		-f bin/software.hex  \
		-v $(BRPATH)/templates/obj_code_pkg_template.vhdl \
		--xcode $(XCODE_SIZE) --xdata $(XDATA_SIZE) -n $(TEST) \
		-o $(VHDL_TB_PATH)/obj_code_pkg.vhdl

#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean
clean:
	-$(RM) -rf bin/* lst/* $(VHDL_TB_PATH)/obj_code_pkg.vhdl
