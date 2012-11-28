#!/bin/bash
#
# This script is fully siiick. It checks if a given service is running. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011030901
#
# USAGE         : ./service.sh {service} {enabled|disabled}
# 
# Example: ./service.sh samba enabled
# OK - CIFS is enabled
#
#Ensure service and status are passed as command-line arguments
if [ -z "$1" -o -z "$2" ]
then
 echo "Please include two arguments, eg."
 echo "Usage: $0 {service} {enabled|disabled}"
 echo "Example :-"
 echo "$0 samba enabled"
exit 3
fi

STATUS=`/usr/bin/isi service $1 |awk '{print $4}'|awk -F. '{print $1}'`

if [ "$1" = "samba" ]
then
  SERVICE=CIFS
else
  SERVICE=$1
fi

if [ "$STATUS" != "$2" ]
then
  echo "CRITICAL - $SERVICE is not $2"
  exit 2
 else
  echo "OK - $SERVICE is $2"
  exit 0
fi

