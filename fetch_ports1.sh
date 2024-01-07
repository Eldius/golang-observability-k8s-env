#!/bin/bash
#
# discoverService - extract the externally visible Node-IP and port for a specific Service in Kubernetes
#
KUBECTL=kubectl
#
if [[ $# < 2 || "$1" == "-h" ]]
    then
    echo discoverService SERVICENAME INTERNALPORT
    exit -1
fi
SERVICENAME=$1
INTERNALPORT=$2

EXTPORT=`${KUBECTL} get svc $SERVICENAME -o=jsonpath="{.spec.ports[?(@.port==${INTERNALPORT})].nodePort}"`

EXTIP=`${KUBECTL} get svc $SERVICENAME --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"`


if [[ -z $EXTPORT ]]
    then
    echo -e "ERROR: service=$SERVICENAME internal-port=$INTERNALPORT not found.\n"
    exit -2
elif [[ -z $EXTIP ]]
    then
    echo -e "ERROR: could not retrieve underlying node IPs.\n"
    exit -2
fi
# Success...
echo $EXTIP:$EXTPORT
