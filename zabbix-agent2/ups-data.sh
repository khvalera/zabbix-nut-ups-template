#!/bin/bash

#====================================================
# https://github.com/khvalera/zabbix-nut-ups-template
#====================================================

ups=$1
key=$2
if [ "$key" == "ups.state.mode" ]; then
   state=`/bin/upsc $ups ups.status 2>&1 | grep -v SSL`
   if [[ ! -z `echo $state | grep "OL"` ]]; then
      echo 1;
   elif [[ ! -z `echo $state | grep "OB"` ]]; then
      echo 2;
   elif [[ ! -z `echo $state | grep "BYPASS"` ]]; then
      echo 3;
   elif [[ ! -z `echo $state | grep "OFF"` ]]; then
      echo 4;
   elif [[ ! -z `echo $state | grep "FSD"` ]]; then
      echo 5;
   else
      echo 0;
   fi
# Voltage stabilization
elif [ "$key" == "ups.state.stab" ]; then
   state=`/bin/upsc $ups ups.status 2>&1 | grep -v SSL`
   if [[ ! -z `echo $state | grep "TRIM"` ]]; then
      echo 1;
   elif [[ ! -z `echo $state | grep "BOOST"` ]]; then
      echo 2;
   else
      echo 0;
   fi
# The battery is charging or discharging
elif [ "$key" == "battery.charg_discharg" ]; then
   state=`/bin/upsc $ups ups.status 2>&1 | grep -v SSL`
   if [[ ! -z `echo $state | grep "CHRG"` ]]; then
      echo 1;
   elif [[ ! -z `echo $state | grep "DISCHRG"` ]]; then
      echo 2;
   else
      echo 0;
   fi
# Battery low or high
elif [ "$key" == "battery.low_high" ]; then
   state=`/bin/upsc $ups ups.status 2>&1 | grep -v SSL`
   if [[ ! -z `echo $state | grep "LB"` ]]; then
      echo 1;
   elif [[ ! -z `echo $state | grep "HB"` ]]; then
      echo 2;
   else
      echo 0;
   fi
# The battery needs to be replaced
elif [ "$key" == "battery.replaced" ]; then
   if [[ ! -z `echo $state | grep "RB"` ]]; then
      echo 1;
   else
      echo 0;
   fi
else
   /bin/upsc $ups $key  2>&1 | grep -v SSL
fi
