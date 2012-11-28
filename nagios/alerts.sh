#!/bin/bash
#
# This script is fully siiick. It checks if there are any alerts on the Isilon Cluster. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011031601
#
# USAGE         : ./alerts.sh
# 
# Example: ./alerts.sh
# OK - No Alerts detected.
#
ALERTHEADER=`/usr/bin/isi alerts | head -1`
ALERT=`/usr/bin/isi alerts | sed '/^ID/ d'|awk '{print $5}'`

#Check if any alerts have been detected
if echo $ALERTHEADER | grep -q ^ID
 then
     #Check if the alert is Informational or Warning
     if echo $ALERT | egrep -q "I|W"
      then
          echo "WARNING - Alert/s detected, please check the Isilon Cluster immediately."
          exit 1
      else
          echo "CRITICAL - Alert/s detected, please check the Isilon Cluster immediately."
          exit 2
     fi
 else
     echo "OK - No Alerts detected."
     exit 0
fi

