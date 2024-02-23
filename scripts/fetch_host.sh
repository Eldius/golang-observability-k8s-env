#!/bin/bash
#
# discoverService - extract the externally visible Node-IP and port for a specific Service in Kubernetes
#
KUBECTL=kubectl
#
if [[ $# < 2 || "$1" == "-h" ]]
    then
    echo discoverService SERVICENAME NAMESPACE
    exit -1
fi
SERVICENAME=$1
NAMESPACE=$2

if [[ -z $NAMESPACE ]]
then
    NAMESPACE="default"
fi

KUBECTL_OPTS="--request-timeout 10s"

# EXTPORT=`${KUBECTL} get svc $SERVICENAME -n $NAMESPACE -o=jsonpath="{.spec.ports[?(@.port==${INTERNALPORT})].nodePort}"`
# kubectl get svc -n databases postgres --output=yaml -o=go-template='{{ (index .status.loadBalancer.ingress 0).ip  }}'

EXTIP=`${KUBECTL} ${KUBECTL_OPTS} get svc $SERVICENAME -n $NAMESPACE -o=go-template='{{ (index .status.loadBalancer.ingress 0).ip  }}'`


if [[ -z $EXTIP ]]
    then
    echo -e "ERROR: could not retrieve underlying node IPs.\n"
    exit -2
fi
# Success...
echo $EXTIP
