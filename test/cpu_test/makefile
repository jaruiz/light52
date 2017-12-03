#-- Build CPU test program and create VHDL package with object code ------------
#
# This makefile works standalone; the CPU tester uses the old assembly syntax
# of ASEM51, not compatible to SDCC's ASxxxx, so this build does not share 
# tools or config with the others.
# It's also a bit special in that the program is a single assembl file.

# Test name (same as dir name).
TEST = cpu_test
# Root file name of the only source file in this test.
SRCFILE = tb51_cpu
# XROM size in bytes. The CPU tester needs a bit more than 33K ox XCODE.
XCODE_SIZE = 40000
# XRAM size in bytes -- the minimum of 512 bytes will do.
XDATA_SIZE = 512

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
AFLAGS = --includes=../include $(BCD_FLAG)
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
