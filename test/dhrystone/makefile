#-- Target 'all' will build an object code VHDL package ready for synthesis ----

#-- Project configuration ------------------------------------------------------

# Directories              
BINDIR = bin
OBJDIR = obj
SRCDIR = src
BRPATH = ../../tools/build_rom
VHDL_TB_PATH = .
COMDIR = ../common

# The parameters we set here will end in the object code VHDL package and will 
# be passed to the MCU core as generics.

PROJ_NAME = Dhrystone
# XROM size in bytes.
XCODE_SIZE = 12288
# XRAM size in bytes.
XDATA_SIZE = 2048


# Source files 
TEST_SRC :=  $(SRCDIR)/dhry21a.c $(SRCDIR)/dhry21b.c \
        $(SRCDIR)/estubs.c $(SRCDIR)/timers_b.c

# Final executable HEX file
BIN :=  software.hex

# Toolchain flags
# Note we ignore many of the warnings triggered by dhrystone
LFLAGS = --model-large
CFLAGS = -DNOSTRUCTASSIGN=1 --model-large \
         --disable-warning 85 --disable-warning 84 --disable-warning 93


# Include the main makefile body with all the rules.
include ../include/common.mk
