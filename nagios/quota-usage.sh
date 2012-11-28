#!/bin/bash
#
# This script is fully siiick. It checks if quota usage is greater than a user defined limit. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011030801
#
# USAGE         : ./quota-usage.sh {quota} {warning} {critical}
#
# Example: ./quota-usage.sh group 20 10
# OK - Used = 2.2G, Quota = 10240G, Free = 10237.8G | QuotaUsage=2.2 ; QuotaTotal=10240 ; QuotaFree=10237.8
#
# Note: the option exists to NOT test for a threshold. Specifying 0 (zero) for both warning and critical will always return an exit code of 0.
#
#Ensure warning and critical limits are passed as command-line arguments
if [ -z "$1" -o -z "$2" -o -z "$3"  ]
then
 echo "Please include three arguments, eg."
 echo "Usage: $0 {quota} {warning} {critical}"
 echo "Example :-"
 echo "$0 group 20 10"
exit 3
fi

#Disable nagios alerts if warning and critical limits are both set to 0 (zero)
if [ $2 -eq 0 ]
 then
  if [ $3 -eq 0 ]
   then
    ALERT=false
  fi
fi
        
#Ensure warning is greater than critical limit
if [ $2 -lt $3 ]
 then
  echo "Please ensure warning is greater than critical, eg."
  echo "Usage: $0 20 10"
  exit 3
fi

NAME=`echo $1`

case "`echo ${NAME}`" in
'ev')
USAGE=`isi quota ls |grep "${NAME} "|awk '{ print $2, $6, $NF }'`
;;
'home')
USAGE=`isi quota ls |grep "${NAME} "|awk '{ print $2, $6, $NF }'`
;;
'nfs')
USAGE=`isi quota ls |grep "${NAME} "|awk '{ print $2, $6, $NF }'`
;;
'vmware')
USAGE=`isi quota ls |grep "${NAME} "|awk '{ print $2, $6, $NF }'`
;;
*)
USAGE=`isi quota ls |grep "${NAME} "|awk '{ print $2, $4, $NF }'`
;;
esac

QUOTA=`echo "$USAGE"|awk '{print $2}'|sed -e 's/[a-zA-Z]//g'`
QUOTA_UNIT=`echo "$USAGE"|awk '{print $2}'|sed -e 's/[0-9.]//g'`
USED=`echo "$USAGE"|awk '{print $3}'|sed -e 's/[a-zA-Z]//g'`
USED_UNIT=`echo "$USAGE"|awk '{print $3}'|sed -e 's/[0-9.]//g'`

case "`echo ${USED_UNIT}`" in
'B')
USED_GB=0
;;
'K')
USED_GB=0
;;
'G')
USED_GB=$USED
;;
'M')
USED_GB=$(bc << EOF
scale = 2
$USED / 1024
EOF
)
;;
'T')
USED_GB=$(bc << EOF
scale = 1
$USED * 1024
EOF
)
;;
esac

case "`echo ${QUOTA_UNIT}`" in
'B')
USED_GB=0
;;
'K')
USED_GB=0
;;
'G')
QUOTA_GB=$QUOTA
;;
'M')
QUOTA_GB=$(bc << EOF
scale = 2
$QUOTA / 1024
EOF
)
;;
'T')
QUOTA_GB=$(bc << EOF
scale = 1
$QUOTA * 1024
EOF
)
;;
esac

FREE_GB=$(bc << EOF
($QUOTA_GB - $USED_GB)
EOF
)
FREE_GB2=`echo "$FREE_GB"|awk -F. '{print $1}'`

#Display Quota Usage without alert
if [ "$ALERT" == "false" ]
 then
     		echo "OK - Used = ${USED_GB}G, Quota = ${QUOTA_GB}G, Free = ${FREE_GB}G | QuotaUsage=${USED_GB} ; QuotaTotal=${QUOTA_GB} ; QuotaFree=${FREE_GB}"
                exit 0
 else
        ALERT=true
fi

#Display Quota Usage with alert
if [ $FREE_GB2 -le "$3" ]
then
  echo "CRITICAL - Used = ${USED_GB}G, Quota = ${QUOTA_GB}G, Free = ${FREE_GB}G | QuotaUsage=${USED_GB} ; QuotaTotal=${QUOTA_GB} ; QuotaFree=${FREE_GB}"
  exit 2
 else
  if [ $FREE_GB2 -le "$2" ]
   then
     echo "WARNING - Used = ${USED_GB}G, Quota = ${QUOTA_GB}G, Free = ${FREE_GB}G | QuotaUsage=${USED_GB} ; QuotaTotal=${QUOTA_GB} ; QuotaFree=${FREE_GB}"
     exit 1
   else
     echo "OK - Used = ${USED_GB}G, Quota = ${QUOTA_GB}G, Free = ${FREE_GB}G | QuotaUsage=${USED_GB} ; QuotaTotal=${QUOTA_GB} ; QuotaFree=${FREE_GB}"
     exit 0
  fi
fi


