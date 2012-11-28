#!/bin/bash
#
# This script is fully siiick. It checks if storage usage is greater than a user defined limit. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011040701
#
# USAGE         : ./storage-usage.sh {warning} {critical}
#
# Example: ./storage-usage.sh 20 10
# OK - Used = 23%, Size = 20T, Available = 77%, Free = 67T, Quota Usage = 9T, Snapshot Usage = 4.1T, RAID = 6.9T, Total (RAW) = 88T | StorageUsage=23 ; StorageSize=20 ; StorageAvailable=77 ; StorageFree=67 ; QuotaUsage=9 ; SnapshotUsage=4.1 ; RaidUsage=6.9 ; TotalSize=88
#
# Note: the option exists to NOT test for a threshold. Specifying 0 (zero) for both warning and critical will always return an exit code of 0.
#
#Ensure warning and critical limits are passed as command-line arguments
if [ -z "$1" -o -z "$2" ]
then
 echo "Please include two arguments, eg."
 echo "Usage: $0 {warning} {critical}"
 echo "Example :-"
 echo "$0 20 10"
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
        
#Ensure warning is greater than critical limit
if [ $1 -lt $2 ]
 then
  echo "Please ensure warning is greater than critical, eg."
  echo "Usage: $0 20 10"
  exit 3
fi

USAGE=`isi stat|grep ^Used`
SIZE=`echo "$USAGE"|awk '{print $2}'|awk -FT '{print $1}'`
SIZEPERC=`echo "$USAGE"|awk '{print $3}'|sed -e 's/[()%]//g'`
AVAIL=`echo "$USAGE"|awk '{print $5}'|awk -FT '{print $1}'`
AVAILPERC=`echo "$USAGE"|awk '{print $6}'|sed -e 's/[()%]//g'`

#Calculate Quota Usage
COUNT=0
FILENAME=/tmp/$$.out
isi quota ls | egrep -v "Usage|^--" | while read line
do
	UNIT=`echo $line|awk '{print $7}' | sed -e 's/[0-9.]//g'`
	SIZE=`echo $line|awk '{print $7}' | sed -e 's/[A-Z]*$//g'`
		case $UNIT in 
		'B' | 'K')
		SIZE_GB=0
		;;
		'M')
		SIZE_GB=`echo $SIZE/1024 | bc -l`
		;;
		'G')
		SIZE_GB=$SIZE
		;;
		'T')
		SIZE_GB=`echo $SIZE*1024 | bc -l`
		;;
		esac
	COUNT=`echo $COUNT+$SIZE_GB|bc`
	printf "%1.0f\n" $COUNT > $FILENAME
done

QUOTAUSAGE=`cat $FILENAME`
QUOTAUSAGE_TB=`echo $QUOTAUSAGE/1024|bc`

rm -f $FILENAME

#Calculate Snapshot Usage
USAGE=`isi snapshot usage|tail -1`
SNAPSIZE=`echo "$USAGE"|awk '{print $1}'|sed -e 's/[a-zA-Z]//g'`
SNAPSIZE_UNIT=`echo "$USAGE"|awk '{print $1}'|sed -e 's/[0-9.]//g'`

case "`echo ${SNAPSIZE_UNIT}`" in
'T')
SNAPSIZE_TB=$SNAPSIZE
;;
'K')
SNAPSIZE_TB=0
;;
'M')
SNAPSIZE_TB=0
;;
'G')
SNAPSIZE_TB=$(bc << EOF
scale = 1
$SNAPSIZE / 1024
EOF
)
;;
esac

#Calculate Total Raw Storage
TOTALUSAGE=`isi stat|grep ^Size`                        
TOTALSIZE=`echo "$TOTALUSAGE"|awk '{print $2}'|awk -FT '{print $1}'`

#Calculate RAID Usage
RAIDSIZE_TB=`echo ${SIZE}-${QUOTAUSAGE_TB}-${SNAPSIZE_TB}|bc`

#Display Storage Usage without alert
if [ "$ALERT" == "false" ]
 then
     		echo "OK - Used = ${SIZEPERC}%, Size = ${SIZE}T, Available = ${AVAILPERC}%, Free = ${AVAIL}T, Quota Usage = ${QUOTAUSAGE_TB}T, Snapshot Usage = ${SNAPSIZE_TB}T, RAID = ${RAIDSIZE_TB}T, Total (RAW) = ${TOTALSIZE}T | StorageUsage=${SIZEPERC} ; StorageSize=${SIZE} ; StorageAvailable=${AVAILPERC} ; StorageFree=${AVAIL} ; QuotaUsage=${QUOTAUSAGE_TB} ; SnapshotUsage=${SNAPSIZE_TB} ; RaidUsage=${RAIDSIZE_TB} ; TotalSize=${TOTALSIZE}"
                exit 0
 else
        ALERT=true
fi

#Display Storage Usage with alert
if [ $AVAILPERC -le "$2" ]
then
  echo "CRITICAL - Used = ${SIZEPERC}%, Size = ${SIZE}T, Available = ${AVAILPERC}%, Free = ${AVAIL}T, Quota Usage = ${QUOTAUSAGE_TB}T, Snapshot Usage = ${SNAPSIZE_TB}T, RAID = ${RAIDSIZE_TB}T, Total (RAW) = ${TOTALSIZE}T | StorageUsage=${SIZEPERC} ; StorageSize=${SIZE} ; StorageAvailable=${AVAILPERC} ; StorageFree=${AVAIL} ; QuotaUsage=${QUOTAUSAGE_TB} ; SnapshotUsage=${SNAPSIZE_TB} ; RaidUsage=${RAIDSIZE_TB} ; TotalSize=${TOTALSIZE}"
  exit 2
 else
  if [ $AVAILPERC -le "$1" ]
   then
     echo "WARNING - Used = ${SIZEPERC}%, Size = ${SIZE}T, Available = ${AVAILPERC}%, Free = ${AVAIL}T, Quota Usage = ${QUOTAUSAGE_TB}T, Snapshot Usage = ${SNAPSIZE_TB}T, RAID = ${RAIDSIZE_TB}T, Total (RAW) = ${TOTALSIZE}T | StorageUsage=${SIZEPERC} ; StorageSize=${SIZE} ; StorageAvailable=${AVAILPERC} ; StorageFree=${AVAIL} ; QuotaUsage=${QUOTAUSAGE_TB} ; SnapshotUsage=${SNAPSIZE_TB} ; RaidUsage=${RAIDSIZE_TB} ; TotalSize=${TOTALSIZE}"
     exit 1
   else
     echo "OK - Used = ${SIZEPERC}%, Size = ${SIZE}T, Available = ${AVAILPERC}%, Free = ${AVAIL}T, Quota Usage = ${QUOTAUSAGE_TB}T, Snapshot Usage = ${SNAPSIZE_TB}T, RAID = ${RAIDSIZE_TB}T, Total (RAW) = ${TOTALSIZE}T | StorageUsage=${SIZEPERC} ; StorageSize=${SIZE} ; StorageAvailable=${AVAILPERC} ; StorageFree=${AVAIL} ; QuotaUsage=${QUOTAUSAGE_TB} ; SnapshotUsage=${SNAPSIZE_TB} ; RaidUsage=${RAIDSIZE_TB} ; TotalSize=${TOTALSIZE}"
     exit 0
  fi
fi

