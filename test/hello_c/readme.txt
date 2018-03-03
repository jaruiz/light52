Hello_c --  This is your typical 'Hello World!' in C.

This demo will just print a welcome message to the serial port (19200/8/N/1).

In order to make this demo, you need the free C compiler SDCC and some flavor
of 'make' -- see the makefile.

Running 'make all' will compile the demo and build a suitable object
code VHDL package that can then be used in synthesis or simulation.
See the makefile for other make targets ('clean', etc.).

You can run this demo on the software simulator B51 and on the simulated 
RTL on GHDL with the makefile at /sim/ghdl. The makefile will compare the 
execution logs of both platforms as part of the test scheme -- see the readmes.
