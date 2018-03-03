This directory contains a number of software demos, small programs meant to
demostrate usage of the light52 core.

All the demos use either the ASEM51 assembler or the SDCC compiler. Eac of them
includes a makefile that can be invoked standalone to build the SW but can also 
be invoked indirectly form the simulation makefile found in /sim/ghdl.

All the demos target the default MCU built around the CPU core, for which basic 
support code is included in directory 'common'.

Please see file /doc/quickstart.txt for instructions on building a demo on
actual hardware. Also look at the synthesis scripts in directory /syn.

Software demos:
----------------

blinker:        LED blinker & second counter. Uses timer and IO ports.
cpu_test:       Executes and tests all opcodes -- very basic, not exhaustive.
hello_asm:      'Hello World' in assembler.
hello_c:        'Hello World' in C. Demonstrates usage of SDCC with light52.
irq_test:       Basic test of interrupt handling, including timer.
dhrystone:      Port of Dhrystone.

All the tests except 'blinker' and 'irq_test' can be run with identical results 
on both iss and RTL simulations, making them suitable for cosimulation testing.
See the simulation makefile. 


Support directories shared by all demos:
-----------------------------------------

include:        C and ASM include files, plus makefile include.
common:         C 'board support package' plus other common files.

