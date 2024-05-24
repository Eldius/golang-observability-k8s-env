#!/bin/bash

CLUSTER_HOST="192.168.0.195:9200"

echo ""
echo "####################"
echo "## creating index ##"
echo "####################"
echo ""

while ! curl --fail -i --insecure -XGET https://${CLUSTER_HOST}/_cluster/health -u 'admin:admin' | grep -E '("status":"yellow"|"status":"green")'
do
    sleep 3
  echo "Still waiting..."
done



echo ""
echo "####################"
echo "## up and running ##"
echo "####################"
echo ""
