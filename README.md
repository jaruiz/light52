light52
=======

Yet another free 8051 FPGA core.

This is a 6-clocker-equivalent implementation of the MCS51 architecture, aiming at area performance.

## Status

This project has been frozen in a relatively immature state: 

* Already tried on real hardware (Dhrystone demo on Cyclone-2 FPGA).
* No documentation other than this readme file and a draft of the datasheet.
* Has not yet passed a rigorous test bench.
* Project still contains many remnants of its OpenCores, Windows-centric past (from dodgy makefiles to CRLF's in sources).


The core has already passed a basic test bench and executed a Dhrystone benchmark
on actual hardware (DE-1 board from Terasic), compiled with SDCC (source and benchmark 
results included -- see datasheet). Yet, there are still many loose ends and a strong test bench 
has yet to be developed.

All the core features are described in detail [in the core datasheet](https://github.com/jaruiz/light52/blob/master/doc/light52_ds.pdf?raw=true).


### Synthesis Results 

These are the synthesis results for the Dhrystone demo using the synthesis scripts supplied:

| Device                  | Clock    | Slack   | Module                 | Logic   | RAM    | Other  |
| ---                     | ---      | ---     | ---                    | ---     | ---    | ---    |
| Altera Cyclone-2 (-C7)  | 50.0 MHz | 0.4ns   | Total for MCU          | 1308LEs | 29M4K  | 1MUL9  |
|                         |          |         | Timer                  | 84LEs   | -      | -      |
|                         |          |         | UART                   | 143LEs  | -      | -      |
|                         |          |         | CPU                    | 1032LEs | 1M4K   | 1MUL9  |
| Xilinx Zynq (-1)        | 50.0 MHz | 3.97ns  | Total for MCU          | 900LUTs | 2RB36+2RB18 | -       |
|                         |          |         | Timer                  | 22LEs   | 2RB36+1RB18      | -      |
|                         |          |         | UART                   | 55LEs   | -      | -      |
|                         |          |         | CPU                    | 811LUTs | 1RB18  | -      |

_Please note that the results include the BRAM blocks that make up the XCODE and XDATA memory for the SW in question.   
The object code package includes constants used to dimension XCODE and XDATA memory and the XCODE memory is synthesized as a ROM initialized with the SW object code; that's why the software is relevant to the synthesis at all._

Synthesis scripts for a couple of development boards can be found here: 

| Target        |  Device          |  Scripts            |
| ---           | ---              | ---                 |
| Terasic DE1   | Altera Cyclone-2 | `syn/de1_quartus2`  |
| Digilent ZYBO | Xilinx Zynq      | `syn/zybo_vivado`   |

The synth scripts will build a minimal wrapper around the MCU entity allowing you to run trials on the core with 
relative ease, or so I hope. 

The [original version of this project, found in Opencores](http://opencores.org/project,light52) was also
synthesized for a Xilinx Spartan-3 target; results can be found in the Opencores page and in section 9 of
[the datasheet](https://github.com/jaruiz/light52/blob/master/doc/light52_ds.pdf?raw=true).  
I no longer have a viable Xilinx toolchain for Spartan 3, which is a shame because that's the platform this core was originally optimized for (size of BRAMs, size of LUTs).


### Next Steps

If I ever have any quality spare time again, I'd like to make this project actually useable in real life projects.  This will involve at least the following:

* A stronger test bench. This is by far the most important.
* An usage tutorial, single-stepping the creation of a simple project around the core.
* Some basic design documentation, necessary for maintenance.
* A detailed explanation of the cosimulation feature used by the test scheme.
* Better comments in the ISS source code.
* A decent command line interface for the ISS.
* Some support for cycle-accurate simulation of peripherals.


Also, the core needs some sort of on-chip debugging capability, ideally something that can be plugged on to an existing IDE. This feature is arguably not strictly necessary for the kind of project this core is better suited to, but I'm afraid it's going to be seen as a must for projects in which the CPU interacts with off-chip devices.

So, to summarize, the project is stalled a bit short of completion. However, it can be used with very little effort in any project where the risk of using a weakly verified CPU is acceptable.

### Warning

Until the core passes a really exhaustive test bench, you use this core at your
own risk -- it has worked so far but it may still have bugs.
If you want to try it anyway, check out file /doc/quickstart.txt and 
don't hesitate to contact me if you need help!


### Refactor in Progress

This project was moved form Opencores to GitHub (see below) and has since been refactored.  
*_TL;DR:_ No need to look at the old Opencores version at all.*

For the sake of completeness, these are the differences vs. the original version:

+ The RTL is largely the same...
+ ...but only this repo will ever be updated; Opencores' will remain inactive.
+ RTL simulation used to rely on Modelsim scripts, now relies on GHDL.
+ No more BAT files to drive SW build, using simple makefiles instead. 
+ Only one of the SW demos tested on HW (blinker)...
+ ...but all tested on iss and/or rtl simulations.
+ Dhrystone demo not yet tested on HW...
+ ...whereas the version in Opencores was. And this is kind of the centerpiece of the 'test' scheme.

In short, this repo is meant to become the only version of this core. No need to look at the old Opencores version.

At the time of writing this (early March 2018) some traces remain of the old Windows-centric version, mostly DOS newlines in some files. This will be corrected progressively as (if) I move the project forward.


## Project replicated in OpenCores

This project started life in [Opencores](http://opencores.org/project,light52) before being moved here in 2016 or so. 

The Opencores version will remain frozen there for as long as Opencores itself is up.  
This GitHub version supersedes the old Opencores version.
