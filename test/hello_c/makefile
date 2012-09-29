#-- Target 'all' will build an object code VHDL package ready for synthesis ----

#-- Toolchain executables ------------------------------------------------------

# FIXME only tested in Win32/Cygwin host. This may not work in a vanilla Win32.

AS = 
CC = SDCC
LD = SDCC
RM = rm
CP = cp

#-- Configuration of the MCU ---------------------------------------------------

# The parameters we set here will end in the object code VHDL package and will 
# be passed to the MCU core as generics.

# XROM size in bytes.
XROM_SIZE = 16384 
# XRAM size in bytes.
XRAM_SIZE = 1024

#-- Project directories, files and flags ---------------------------------------
 
# Directories              
BINDIR = bin
OBJDIR = obj
SRCDIR = src
BRPATH = ../../tools/build_rom
VHDL_TB_PATH = .

# Source files 
SRC :=  $(SRCDIR)/hello.c
# Final executable HEX file
BIN :=  hello.ihx

# Toolchain flags 
LFLAGS = -o $(OBJDIR)/ 
CFLAGS = -o $(OBJDIR)/
AFLAGS = -c

#-- A bit of 'make magic' to simplify the rules

# Add all the source directories to the VPATH... 
VPATH := $(dir $(SRC))
# ...and build the OBJS list from the list of sources
OBJS := $(patsubst %.c, $(OBJDIR)/%.rel, $(notdir $(SRC)))


#-- Targets & rules ------------------------------------------------------------

# Compile C sources into relocatable object files
$(OBJDIR)/%.rel : $(SRCDIR)/%.c
	@echo Compiling $< ...
	$(CC) $(CFLAGS) -c $<

# Build executable file and move it to the bin directory
$(BINDIR)/$(BIN): $(OBJS)
	@echo Building executable file $@ ...
	$(LD) $(OBJS) $(LFLAGS)
	$(CP) $(OBJDIR)/$(BIN) $(BINDIR)/$(BIN)

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
		-o $(VHDL_TB_PATH)/obj_code_pkg.vhdl

#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) $(OBJDIR)/*.* $(BINDIR)/*.* $(VHDL_TB_PATH)/obj_code_pkg.vhdl
