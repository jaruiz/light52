### Build scripts -- light52 demo on Digilent's ZYBO board using Vivado.

These scripts will build the project bit stream file using Vivado's non-project 
flow mode. The only step not covered in the scripts is loading the bit stream on 
the target board itself (for which I use the Vivado GUI).

The main build script has been mostly copied from the example in page 11 of the
Vivado Tcl scripting guide (ug894, 'Using Tcl Scripting'). 

Output files, including the bit stream, will be created within `zybo_demo`.


### Usage

+ `build.sh` will launch the synthesis flow. 
+ `delete.sh` will clean the directory.
+ `quickreport.sh` will extract a very brief summary from Vivado's run log.

None of the scripts take any parameters or need you to modify the environment.  
The path to the Vivado install is hardcoded in `settings.sh` so you'll probably need to adapt it. 


### Files

| File              | What the file is                                        |
| ---               | ---                                                     |
| `settings.sh`     | Runs Vivado's `settings` shell script.                  |
| `build.sh`        | Invokes `build.tcl` in Vivado.                          |
| `build.tcl`       | Runs synth and implementation, creates bitstream file.  |
| `delete.sh`       | Deletes all output, leaves dir in repo condition.       |
| `quickreport.sh`  | Greps run log for errors and warnings.                  |
| `README.md`       | This file.                                              |


### Dependencies

Script `build.tcl` contains a list of source files and constraint file(s).  
All the target HW dependencies (ZYBO board) ard contained in the constraints
file. These scripts should be target-agnostic, mostly.


### Build MCS51 Code Before Synthesis

The build needs a vhdl package to initialize the 8051 code memory.   
Script `build.tcl` will point to one of the test samples supplied with the light52
project (see variable `OBJ_CODE_DIR` in `build.tcl`). You need to make sure the SW
is built before the synthesis is launched.

For instance, to build the test `blinker`:

    make -C ../../test/blinker/ clean package
  

That'll build the vhdl package with the object code in the test directory, where `build.tcl`
expects to find it.  
(You need SDCC installed for that to work, BTW.)


Conveniently, the repository includes pre-built vhdl object code packages for all tests.



### Compatibility

This has been tested with Vivado 2015.4 and 2016.2 running on a Linux machine.


