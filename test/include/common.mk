#-- common.mk - Makefile include common to all test and demo programs ----------
#
# This make include file should be included in a project makefile *after* the 
# project configuration variables have been defined. See the Dhrystone makefile 
# for an usage example.

#-- Toolchain executables ------------------------------------------------------

# TODO won't work with assembly tests and will need changes in Win32.
AS = 
CC = sdcc
LD = sdcc
RM = rm -rf
CP = cp
BRPATH = ../../tools/build_rom

#-- Common configuration for all tests -----------------------------------------

# Directories              
BINDIR = bin
OBJDIR = obj
SRCDIR = src
VHDL_TB_PATH = .
COMDIR = ../common

# Toolchain flags 
LFLAGS = -o $(OBJDIR)/ --code-size $(XCODE_SIZE) --xram-size $(XDATA_SIZE) 
CFLAGS = -o $(OBJDIR)/ -D__LIGHT52__=1
AFLAGS = -c


#-- Sources and objects, same for all tests  -----------------------------------

# Add all the source directories to the VPATH.
VPATH := $(dir $(SRC))

# If no list of sources is specified, just compile all c files in src.
SRC ?=  $(wildcard $(SRCDIR)/*.c)
OBJS ?= $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.rel, $(SRC))
# Default name of hex file.
BIN ?= software.hex

#-- Targets & rules ------------------------------------------------------------

# Compile C sources into relocatable object files
$(OBJDIR)/%.rel : src/%.c
	@echo Compiling $< ...
	$(CC) $(CFLAGS) -c $<

# Build executable file and move it to the bin directory
$(BINDIR)/$(BIN): $(OBJS)
	@echo Building executable file $@ ...
	$(LD) $(OBJS) $(LFLAGS)
	$(CP) $(OBJDIR)/*.ihx $(BINDIR)/$(BIN)

# Root target
.PHONY: sw
sw: $(BINDIR)/$(BIN) package
	@echo Done


#-- Targets that build the synthesizable vhdl ----------------------------------

#-- Create VHDL package with object code and synthesis parameters
.PHONY: package
package: $(BINDIR)/$(BIN)
	@echo Building object code VHDL package...
	@python $(BRPATH)/src/build_rom.py \
		-f $(BINDIR)/$(BIN)  \
		-v $(BRPATH)/templates/obj_code_pkg_template.vhdl \
		--xcode $(XCODE_SIZE) --xdata $(XDATA_SIZE) -n $(PROJ_NAME) \
		-o $(VHDL_TB_PATH)/obj_code_pkg.vhdl

#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean
clean:
	-$(RM) $(OBJDIR)/* $(BINDIR)/* $(VHDL_TB_PATH)/obj_code_pkg.vhdl
