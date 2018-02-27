#-- Build assembly source 'hello world' including vhdl obj code package --------

# All we do here is configure the build:

# Test name (same as dir name).
TEST = hello_asm
# Root file name of the only source file in this test.
SRCFILE = hello
# XROM size in bytes.
XCODE_SIZE = 512
# XRAM size in bytes -- the minimum of 512 bytes will do.
XDATA_SIZE = 512
# This will run on a simulated UART so build fake UART TX code etc.
SIMULATED_UART = 1

ifeq ($(BCD),1)
	BCD_FLAG = --define=BCD
else
	BCD =
endif

# The actual build happens in the main makefile fragment.
include ../include/assembler.mk
