#!/bin/bash
#
# This script is fully siiick. It checks the status of a SyncIQ replication job. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011031001
#
# USAGE         : ./replication.sh {job}
# 
# Example: ./replication.sh group_mac
# OK - group_mac is scheduled
#
#Ensure the job name is passed as a command-line argument
if [ -z "$1" ]
then
 echo "Please include one argument, eg."
 echo "Usage: $0 {job}"
 echo "Example :-"
 echo "$0 group_mac"
exit 3
fi

JOB=`echo $1`

STATUS=`isi sync jobs list|grep "${JOB} "|awk -F\| '{print $3 $5}'|cut -c 2-|sed 's/[ \t]*$//'`

if echo "$STATUS"|awk '{print $1}'|egrep -vqi "Running|Scheduled|Success"
then
  echo "CRITICAL - $1 is ${STATUS}"
  exit 2
 else
  echo "OK - $1 is ${STATUS}"
  exit 0
fi

