#-- Target 'all' will build an object code VHDL package ready for synthesis ----

#-- Toolchain executables ------------------------------------------------------

# FIXME only tested in Win32/Cygwin host. This may not work in a vanilla Win32.

AS = 
CC = SDCC
LD = SDCC
RM = rm
CP = cp

#-- Project directories, files and flags ---------------------------------------
 
# Directories              
BINDIR = bin
OBJDIR = obj
SRCDIR = src
BRPATH = ../../tools/build_rom
VHDL_TB_PATH = .
COMDIR = ../common

#-- Project configuration ------------------------------------------------------

# The parameters we set here will end in the object code VHDL package and will 
# be passed to the MCU core as generics.

PROJ_NAME = Dhrystone
# XROM size in bytes.
XCODE_SIZE = 12288
# XRAM size in bytes.
XDATA_SIZE = 2048



# Source files 
SRC :=  $(SRCDIR)/dhry21a.c $(SRCDIR)/dhry21b.c \
        $(SRCDIR)/estubs.c $(SRCDIR)/timers_b.c \
        $(COMDIR)/soc.c
# Final executable HEX file
BIN :=  dhry.ihx

# Toolchain flags
# Note we ignore many of the warnings triggered by dhrystone
LFLAGS = -o $(OBJDIR)/ --model-large --code-size $(XCODE_SIZE) --xram-size $(XDATA_SIZE)
CFLAGS = -o $(OBJDIR)/ -D__LIGHT52__=1 -DNOSTRUCTASSIGN=1 --model-large \
         --disable-warning 85 --disable-warning 84 --disable-warning 93
AFLAGS = -c

#-- A bit of 'make magic' to simplify the rules

# Add all the source directories to the VPATH... 
VPATH := $(dir $(SRC))
# ...and build the OBJS list from the list of sources
OBJS := $(patsubst %.c, $(OBJDIR)/%.rel, $(notdir $(SRC)))


#-- Targets & rules ------------------------------------------------------------

# Compile C sources into relocatable object files
$(OBJDIR)/%.rel : %.c
	@echo Compiling $< ...
	$(CC) $(CFLAGS) -c $<

# Build executable file and move it to the bin directory
$(BINDIR)/$(BIN): $(OBJS)
	@echo Building executable file $@ ...
	$(LD) $(OBJS) $(LFLAGS)
	$(CP) $(OBJDIR)/*.ihx $(BINDIR)/$(BIN)

# Root target
all: $(BINDIR)/$(BIN) package
	@echo Done


#-- Targets that build the synthesizable vhdl ----------------------------------

#-- Create VHDL package with object code and synthesis parameters
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
	-$(RM) $(OBJDIR)/*.* $(BINDIR)/*.* $(VHDL_TB_PATH)/obj_code_pkg.vhdl
