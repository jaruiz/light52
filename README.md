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
on actual hardware (DE-1 board from Terasic) -- benchmark results included in 
the datasheet. Yet, there are still many loose ends and a strong test bench 
has yet to be developed.

If you are curious, you can [take a look at the datasheet](https://github.com/jaruiz/light52/blob/master/doc/light52_ds.pdf?raw=true).


The next step is adding some much-needed 'quick start' document showing how to 
set up the project for development or use, and then a design document explaining
the internals of the core.

In the meantime I am incrementally improving the test bench code, catching and 
fixing bugs until the test bench is strong enough to consider the core 'tested'.


Anyway, until some real documentation is added explaining how to set up and use this
project, you are not advised to try to use it. But don't hesitate to contact 
me if you decide to try and need help!

