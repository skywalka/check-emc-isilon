#!/bin/bash
#
# This script is fully siiick. It checks if snapshot usage is greater than a user defined limit. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011040701
#
# USAGE         : ./snapshot-usage.sh {warning} {critical}
#
# Example: ./snapshot-usage.sh 10 20
# OK - Usage = 4.74%, Size = 4.1T, Total = 88T | SnapshotUsage=4.74 ; SnapshotSize=4.1 ; TotalSize=88
#
# Note: the option exists to NOT test for a threshold. Specifying 0 (zero) for both warning and critical will always return an exit code of 0.
#
#Ensure warning and critical limits are passed as command-line arguments
if [ -z "$1" -o -z "$2" ]
then
 echo "Please include two arguments, eg."
 echo "Usage: $0 {warning} {critical}"
 echo "Example :-"
 echo "$0 10 20"
exit 3
fi

#Disable nagios alerts if warning and critical limits are both set to 0 (zero)
if [ $1 -eq 0 ]
 then
  if [ $2 -eq 0 ]
   then
    ALERT=false
  fi
fi
        
#Ensure warning is less than critical limit
if [ $2 -lt $1 ]
 then
  echo "Please ensure warning is less than critical, eg."
  echo "Usage: $0 10 20"
  exit 3
fi

TOTALUSAGE=`isi stat|grep ^Size`                        
TOTALSIZE=`echo "$TOTALUSAGE"|awk '{print $2}'|awk -FT '{print $1}'`

USAGE=`isi snapshot usage|tail -1`
SIZE=`echo "$USAGE"|awk '{print $1}'|sed -e 's/[a-zA-Z]//g'`
SIZE_UNIT=`echo "$USAGE"|awk '{print $1}'|sed -e 's/[0-9.]//g'`
PERC=`echo "$USAGE"|awk '{print $4}'|awk -F% '{print $1}'`
PERC2=`echo "$PERC"|awk -F. '{print $1}'`

case "`echo ${SIZE_UNIT}`" in
'T')
SIZE_TB=$SIZE
;;
'K')
SIZE_TB=0
;;
'M')
SIZE_TB=0
;;
'G')
SIZE_TB=$(bc << EOF
scale = 1
$SIZE / 1024
EOF
)
;;
esac


#Display Snapshot Usage without alert
if [ "$ALERT" == "false" ]
 then
     		echo "OK - Usage = ${PERC}%, Size = ${SIZE_TB}T, Total = ${TOTALSIZE}T | SnapshotUsage=${PERC} ; SnapshotSize=${SIZE_TB} ; TotalSize=${TOTALSIZE}"
                exit 0
 else
        ALERT=true
fi

#Display Snapshot Usage with alert
if [ $PERC2 -ge "$2" ]
then
  echo "CRITICAL - Usage = ${PERC}%, Size = ${SIZE_TB}T, Total = ${TOTALSIZE}T | SnapshotUsage=${PERC} ; SnapshotSize=${SIZE_TB} ; TotalSize=${TOTALSIZE}"
  exit 2
 else
  if [ $PERC2 -ge "$1" ]
   then
     echo "WARNING - Usage = ${PERC}%, Size = ${SIZE_TB}T, Total = ${TOTALSIZE}T | SnapshotUsage=${PERC} ; SnapshotSize=${SIZE_TB} ; TotalSize=${TOTALSIZE}"
     exit 1
   else
     echo "OK - Usage = ${PERC}%, Size = ${SIZE_TB}T, Total = ${TOTALSIZE}T | SnapshotUsage=${PERC} ; SnapshotSize=${SIZE_TB} ; TotalSize=${TOTALSIZE}"
     exit 0
  fi
fi

