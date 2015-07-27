light52
=======

Yet another free 8051 FPGA core.

This is a 6-clocker-equivalent implementation of the MCS51 architecture, aiming at area performance.

## Status

This project has been frozen in a relatively immature state: 

* Design and implementation finished.
* Already tried on real hardware (Dhrystone demo on Cyclone-2 FPGA).
* No documentation other than this readme file and a draft of the datasheet.
* Has not yet passed a rigorous test bench.


The core has already passed a basic test bench and executed a Dhrystone benchmark
on actual hardware (DE-1 board from Terasic), compiled with SDCC (source and benchmark 
results included -- see datasheet). Yet, there are still many loose ends and a strong test bench 
has yet to be developed.

All the core features are described in detail [in the datasheet](https://github.com/jaruiz/light52/blob/master/doc/light52_ds.pdf?raw=true).

### Next Steps

If I ever have any quality spare time again, I'd like to make this project actually useable in real life projects.  This will involve at least the following:

* A stronger test bench. This is by far the most important.
* An usage tutorial, single-stepping the creation of a simple project around the core.
* Some basic design documentation, necessary for maintenance.
* A detailed explanation of th ecosimulation feature which is the core of the test scheme.
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

## Project replicated in OpenCores

This project is replicated in [Opencores](http://opencores.org/project,light52). The contents of both projects should be identical but, as of this writing, only the Opencores version has been pulled and tested on a board. Which means this version might be incomplete or somehow broken. I have checked but I haven't tested, so if you see anything weird you may consider trying the other version and sending me a message...


