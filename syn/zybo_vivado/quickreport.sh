#!/bin/bash   
# Display a quick summary of errors and warnings.       
NUMERR=$(cat vivado.log | grep -E "ERROR" | wc -l)
echo -e "\e[1;36mError messages:   $NUMERR\e[0m"
cat vivado.log | grep --color -E "ERROR"
NUMWARN=$(cat vivado.log | grep -E "WARNING|CRITICAL WARNING" | wc -l)
echo -e "\e[1;36mWarning messages: $NUMWARN\e[0m"
cat vivado.log | grep --color -E "WARNING|CRITICAL WARNING"
