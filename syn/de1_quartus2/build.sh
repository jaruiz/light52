#!/bin/bash          
echo -e "\e[1;33mRunning Quartus-2 Synth+Impl flow.\e[0m"

# One of the flow tools needs the constraints file to have the same name as 
# the project, so copy it.
cp constraints.sdc de1_demo.sdc
# Replace this with the path for your own Quartus-2 install.
/opt/altera/12.0/quartus/bin/quartus_sh -t build.tcl
