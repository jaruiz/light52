### cpu_test -- Perform a basic test of all the CPU opcodes.

This program will test all the CPU opcodes for basic behavior. Each opcode is
tested at least once. Those opcodes with more complex behavior (e.g. ADD) are
tested with a few 'corner cases', but the test is by no means exhaustive.

In particular, this test bench does not check for unintended side effects.



This program might be modified to run on a physical core, but it is most useful when used with
the simulation log feature -- comparing the simulation logs of the RTL simulation against
those of the software simulator B51 (included as part of this project).
_(The binary executable is about 33KB long and the UART code would need changes to access real HW.)_


#### Building the test

In order to make this demo, you need the free assembler [ASEM51](http://plit.de/asem-51/). Just download, 
unzip and modify the makefile to point at the executable. 

Assuming you've pointed your copy of the makefile at your copy of `asem51` all you need to do is:

    make sw

That'll build the executable program in Intel HEX format and it will also invoke script `tools/build_rom/src/build_rom.py` to generate a VHDL package that contains the object code as an VHDL format that is then used to initialize the ROM model, both in simulation and synthesis -- more details in the relevant READMEs.


#### Simulation

Within directory `sim/ghdl` you'll find a makefile that will build this test and run it on `ghdl` and on the software simulator
`b51` (supplied with this project) and will match the execution logs against each other automatically. Cd to `sim/ghdl` and:

    make TEST=cpu_test clean all

...and be patient because the RTL simulation takes a few minutes.
