#-- See rules in ../include/common.mk ------------------------------------------

#-- Project configuration ------------------------------------------------------

# The parameters we set here will end in the object code VHDL package and will 
# be passed to the MCU core as generics.

PROJ_NAME = "Hello World (ASM)"
# XROM size in bytes.
XCODE_SIZE = 2048
# XRAM size in bytes -- should be zero but the HW does not support that yet.
XDATA_SIZE = 512

# Don't link in the common code.
COMM_OBJS =

# Include the main makefile body with all the rules.
include ../include/common.mk
