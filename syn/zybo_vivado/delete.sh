#!/bin/bash          
echo -e "\e[1;33mDeleting Vivado project and log files.\e[0m"

rm -rf ./zybo_demo.*
rm -rf ./zybo_demo
rm -rf ./.Xil
rm -rf ./vivado*
rm -rf ./usage*

