#!/bin/sh

CLUSTER_HOST="localhost:5601"

echo ""
echo ""
echo "############################"
echo "## creating index pattern ##"
echo "############################"
echo ""

curl --insecure -u 'admin:admin' http://${CLUSTER_HOST}/api/features || exit 1

echo ""
echo ""
echo "#############################################"
echo "## creating index pattern application-logs ##"
echo "#############################################"
echo ""

curl -i \
    --insecure \
    -X POST \
    -u 'admin:admin' \
    "http://${CLUSTER_HOST}/api/saved_objects/index-pattern/application-logs" \
    -H 'osd-xsrf: true' \
    -H 'Content-Type: application/json' \
    -H 'securitytenant: global' \
    -d '{
        "attributes": {
            "title": "application-logs",
            "timeFieldName": "@timestamp"
        }
    }'

echo ""
echo ""


echo ""
echo ""
echo "####################################################"
echo "## creating index pattern custom-application-logs ##"
echo "####################################################"
echo ""

curl -i \
    --insecure \
    -X POST \
    -u 'admin:admin' \
    "http://${CLUSTER_HOST}/api/saved_objects/index-pattern/custom-application-logs" \
    -H 'osd-xsrf: true' \
    -H 'Content-Type: application/json' \
    -H 'securitytenant: global' \
    -d '{
        "attributes": {
            "title": "custom-application-logs",
            "timeFieldName": "time"
        }
    }'

echo ""
echo ""

echo ""
echo "##############################################"
echo "## creating index pattern metrics-otel-v1-* ##"
echo "##############################################"
echo ""

curl -i \
        --insecure \
        -X POST \
        -u 'admin:admin' \
        "http://${CLUSTER_HOST}/api/saved_objects/index-pattern/metrics-otel-v1-*" \
        -H 'osd-xsrf: true' \
        -H 'Content-Type: application/json' \
        -H 'securitytenant: global' \
        -d '{
            "attributes": {
                "title": "metrics-otel-v1-*",
                "timeFieldName": "time"
            }
        }'

# echo ""
# echo "###########################################################"
# echo "## setting default index pattern custom-application-logs ##"
# echo "###########################################################"
# echo ""
# 
# curl -i \
#         --insecure \
#         -X POST \
#         -u 'admin:admin' \
#         "http://${CLUSTER_HOST}/api/index_patterns/default" \
#         -H 'osd-xsrf: true' \
#         -H 'Content-Type: application/json' \
#         -H 'securitytenant: global' \
#         -d '{
#             "index_pattern_id": "custom-application-logs"
#         }'
