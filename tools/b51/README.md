## b51 -- ISS for Light52 (MCS51 clone).

### Building b51

Use make:

	make all 

This will build executable `./bin/b51` assuming you have the gcc toolchain.


### Using b51

This is not a general purpose ISS. It is meant to be used to verify the Light52
core. Accordingly, the command line interface is simple:

	Usage: b51 [options]

	Options:

	  --hex=<filename>       - (mandatory) Name of Intel HEX object code file.
	  --nint=<dec. number>   - No. of instructions to run. Defaults to a gazillion.
	  --nologs               - Disable console and execution logging.

	The program will load the object file, reset the CPU and execute the specified
	number of instructions, then quit.
	Simulation will only stop after <nint> instructions, when the CPU enters a
	single-instruction endless loop or on an error condition.



### Role of b51 in the Light52 project

This ISS is meant to be the golden model in a conventional RTL-vs-ISS CPU 
verification scheme.

The idea is: both platforms run the same code, both output an execution log 
containing per-instruction CPU state deltas, then the log files are compared.
If they match, the RTL is assumed to be OK.

Of course, to be of any use the scheme relies on the correctness of the ISS and 
the thoroughness of the test code. And that's the catch: the ISS was written from
scratch by me (the same guy who wrote the RTL) and the basic opcode test program
was also written from scratch by me and has never been run on any other MCS51 
implementation.

So you can see the whole thing is built on rather shaky verification ground.

Having said that, both RTL and ISS have run nontrivial C code built with SDCC so
they can't be catastrophically wrong. At least one bug is known to remain at 
large, though -- a detailed report will be filed ASAP.

