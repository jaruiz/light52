#-- Build assembly source into hex obj file & vhdl obj code package ------------

# All we do here is configure the build:

# Test name (same as dir name).
TEST = irq_test
# Root file name of the only source file in this test.
SRCFILE = irq_test
# XROM size in bytes.
XCODE_SIZE = 1024
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
