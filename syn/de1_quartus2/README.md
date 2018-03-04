### Build scripts -- light52 MCU demo on Terasic's DE1 board using Quartus-2.

These scripts will build the project bit stream file using the Quartus 2 flow. 
The only step not covered in the scripts is loading the bit stream on the target 
board itself -- for this you can use your favourite tool or you can launch the
Altera IDE.

This script comes alsmost straight form the Altera documentation:

+ [1] "Quartus Prime Standard Edition Handbook Volume 1" (QPS5V1 2016.10.31)
+ [2] "Quartus II Scripting Reference Manual" (MNL-Q2101904-9.1.1, July 2013)

Output files, including the bit stream `'de1_demo.sof'`, will be found on this 
directory.


### Target board

Terasic's DE1: https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=83.

These scripts may be a convenient starting point for other Altera targets.


### USAGE

+ `./build.sh` will launch the synthesis flow. 
+ `./delete.sh` will clean the directory.

You will need to edit file `build.sh` to point at your local Quartus install.

If you need to change the CPU code ROM contents or the pin assignments or other 
constraints, please do so on files `build.tcl` and `constraints.sdc`.


### DEFAULT SOFTWARE

The script as it stands will initialize the code ROM with the 'blinker' demo.  

Switch `SW9` (leftmost) is used as reset; set to 'off' to let the code run and 
you will see a count of seconds progressing on the 7-segment LED display and 
`LED R0` will blink as per blinky tradition.


### FILES

+ `build.sh`            -- Invoke build.tcl in Quartus-2.
+ `build.tcl`           -- Run synth and implementation, create bitstream file.
+ `delete.sh`           -- Deletes all output, leaves dir in repo condition.
+ `constraints.sdc`     -- Constraints file (clk period).
+ `README.md`           -- This file.



### BUILD MCS51 CODE BEFORE SYNTHESIS

The build needs a vhdl package to initialize the MCU code memory. Script 
`build.tcl` will point to one of the pre-compiled test samples supplied with the 
light52 project (see variable `OBJ_CODE_DIR` in `build.tcl`), namely the 'blinker'
demo.  
You need to make sure the SW is built before the synthesis is launched.


### COMPATIBILITY

These scripts have been tested with:
    Quartus II 32-bit Version 12.0 Build 178 05/31/2012 SJ Web Edition

I've run this on Linux.  

Presumably the whole thing can be moved to Windows or to a later version of Q2
with little to no effort -- I hope the tcl API has not changes in this time, 
but I haven't checked. 

If you're building stuff on Altera chips you're likely to know your way around 
the tools much better than I do. 

