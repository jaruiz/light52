light52
=======

Yet another free 8051 FPGA core.

## Status

This project is in a very early state: 

* Design and implementation finished.
* Already tested on real hardware (Dhrystone demo on Cyclone-2 FPGA).
* No documentation other than this readme file and a draft of the datasheet.
* Hardly debugged.


The core has already passed a basic test bench and executed a Dhrystone benchmark
on actual hardware (DE-1 board from Terasic), compiled with SDCC (source and benchmark 
results included -- see datasheet). Yet, there are still many loose ends and a strong test bench 
has yet to be developed.

If you are curious, you can [take a look at the datasheet](https://github.com/jaruiz/light52/blob/master/doc/light52_ds.pdf?raw=true).


The next step is adding some much-needed design document explaining the 
internals of the core, plus a detailed explanation of the cosimulation feature.

Besides, the software simulator is unfinished: it needs better comments, a more 
elaborate command line interface and a cycle-accurate simulation of the 
peripherals.

In the meantime I am incrementally improving the test bench code, catching and 
fixing bugs until the test bench is strong enough to consider the core 'tested'.

Until the core passes a really exhaustive test bench, you use this core at your
own risk -- it has worked so far but it may still have bugs.
If you want to try it anyway, check out file /doc/quickstart.txt and 
don't hesitate to contact me if you need help!

