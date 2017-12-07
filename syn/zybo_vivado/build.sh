#!/bin/bash          
echo -e "\e[1;33mRunning Vivado Synth+Impl non-project flow.\e[0m"

source $(./settings.sh)
vivado -mode batch -source ./build.tcl | grep --color -E '^|ERROR|WARNING|CRITICAL WARNING'

source ./quickreport.sh
