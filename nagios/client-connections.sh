#!/bin/bash
# This script is fully siiick. It checks if the average client connections per node are greater than a user defined limit. Like I said earlier, it's sick.
#
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#
# Author: Luke Harris
#
# version: 2011051201
#
# USAGE         : ./client-connections.sh {warning} {critical}
#
# Example: ./client-connections.sh 25 35
# OK - Active CIFS Clients = 6, Active NFS Clients = 25, Total Active Clients = 31, Connected CIFS Clients = 326, Connected NFS Clients = 108, Total Connected Clients = 434 | ActiveCIFSClients=6 ; ActiveNFSClients=25 ; TotalActiveClients=31 ; ConnectedCIFSClients=326 ; ConnectedNFSClients=108 ; TotalConnectedClients=434
#
# Note: the option exists to NOT test for a threshold. Specifying 0 (zero) for both warning and critical will always return an exit code of 0.
#
#Ensure warning and critical limits are passed as command-line arguments
if [ -z "$1" -o -z "$2" ]
then
 echo "Please include two arguments, eg."
 echo "Usage: $0 {warning} {critical}"
 echo "Example :-"
 echo "$0 25 35"
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
  echo "Usage: $0 25 35"
  exit 3
fi

CLIENTCONNS=`isi statistics query --nodes=all --stats=node.clientstats.active.cifs,node.clientstats.active.nfs,node.clientstats.connected.cifs,node.clientstats.connected.nfs --noheader|grep average`

ACTIVECIFS=`echo $CLIENTCONNS|awk '{print $2}'`
ACTIVENFS=`echo $CLIENTCONNS|awk '{print $3}'`

CONNECTEDCIFS=`echo $CLIENTCONNS|awk '{print $4}'`
CONNECTEDNFS=`echo $CLIENTCONNS|awk '{print $5}'`

TOTALACTIVE=`echo ${ACTIVECIFS}+${ACTIVENFS}|bc`
TOTALCONNECTED=`echo ${CONNECTEDCIFS}+${CONNECTEDNFS}|bc`

#Display Client Connections without alert
if [ "$ALERT" == "false" ]
 then
		echo "OK - Active CIFS Clients = ${ACTIVECIFS}, Active NFS Clients = ${ACTIVENFS}, Total Active Clients = ${TOTALACTIVE}, Connected CIFS Clients = ${CONNECTEDCIFS}, Connected NFS Clients = ${CONNECTEDNFS}, Total Connected Clients = ${TOTALCONNECTED} | ActiveCIFSClients=${ACTIVECIFS} ; ActiveNFSClients=${ACTIVENFS} ; TotalActiveClients=${TOTALACTIVE} ; ConnectedCIFSClients=${CONNECTEDCIFS} ; ConnectedNFSClients=${CONNECTEDNFS} ; TotalConnectedClients=${TOTALCONNECTED}"
                exit 0
 else
        ALERT=true
fi

#Display Client Connections with alert
if [ $ACTIVECIFS -ge "$2" ]
then
  echo "CRITICAL - Active CIFS Clients = ${ACTIVECIFS}, Active NFS Clients = ${ACTIVENFS}, Total Active Clients = ${TOTALACTIVE}, Connected CIFS Clients = ${CONNECTEDCIFS}, Connected NFS Clients = ${CONNECTEDNFS}, Total Connected Clients = ${TOTALCONNECTED} | ActiveCIFSClients=${ACTIVECIFS} ; ActiveNFSClients=${ACTIVENFS} ; TotalActiveClients=${TOTALACTIVE} ; ConnectedCIFSClients=${CONNECTEDCIFS} ; ConnectedNFSClients=${CONNECTEDNFS} ; TotalConnectedClients=${TOTALCONNECTED}"
  exit 2
 else
  if [ $ACTIVECIFS -ge "$1" ]
   then
     echo "WARNING - Active CIFS Clients = ${ACTIVECIFS}, Active NFS Clients = ${ACTIVENFS}, Total Active Clients = ${TOTALACTIVE}, Connected CIFS Clients = ${CONNECTEDCIFS}, Connected NFS Clients = ${CONNECTEDNFS}, Total Connected Clients = ${TOTALCONNECTED} | ActiveCIFSClients=${ACTIVECIFS} ; ActiveNFSClients=${ACTIVENFS} ; TotalActiveClients=${TOTALACTIVE} ; ConnectedCIFSClients=${CONNECTEDCIFS} ; ConnectedNFSClients=${CONNECTEDNFS} ; TotalConnectedClients=${TOTALCONNECTED}"
     exit 1
   else
     echo "OK - Active CIFS Clients = ${ACTIVECIFS}, Active NFS Clients = ${ACTIVENFS}, Total Active Clients = ${TOTALACTIVE}, Connected CIFS Clients = ${CONNECTEDCIFS}, Connected NFS Clients = ${CONNECTEDNFS}, Total Connected Clients = ${TOTALCONNECTED} | ActiveCIFSClients=${ACTIVECIFS} ; ActiveNFSClients=${ACTIVENFS} ; TotalActiveClients=${TOTALACTIVE} ; ConnectedCIFSClients=${CONNECTEDCIFS} ; ConnectedNFSClients=${CONNECTEDNFS} ; TotalConnectedClients=${TOTALCONNECTED}"
     exit 0
  fi
fi

