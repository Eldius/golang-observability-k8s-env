
CLUSTER_IP := 192.168.0.36

ks-opensearch:
	cd opensearch/opensearch; kubectl apply -f .

ks-dashboards:
	cd opensearch/dashboards; kubectl apply -f .

ks-dashboards-down:
	-cd opensearch/dashboards; kubectl delete -f .

ks-data-prepper:
	cd opensearch/data-prepper; kubectl apply -f .

ks-data-prepper-down: ks-data-prepper-configmap-down
	-cd opensearch/data-prepper; kubectl delete -f .

ks-fluent-bit: ks-fluent-bit-configmap
	cd opensearch/fluent-bit; kubectl apply -f .

ks-postgres:
	cd postgres; kubectl apply -f .

ks-postgres-down:
	-cd postgres; kubectl delete -f .

ks-fluent-bit-down: ks-fluent-bit-configmap-down
	-cd opensearch/fluent-bit; kubectl delete -f .

ks-opensearch-down:
	-cd opensearch/opensearch; kubectl delete -f .

ks-data-prepper-configmap:
	-kubectl create configmap data-prepper-config-files --from-file=opensearch/data-prepper/configs

ks-data-prepper-configmap-down:
	-kubectl delete configmap data-prepper-config-files

ks-fluent-bit-configmap:
	-kubectl create configmap fluent-bit-config-files --from-file=opensearch/fluent-bit/configs

ks-fluent-bit-configmap-down:
	-kubectl delete configmap fluent-bit-config-files

ks-opensearch-configmap:
	-kubectl create configmap opensearch-config-files --from-file=opensearch/opensearch/configs

ks-opensearch-configmap-down:
	-kubectl delete configmap opensearch-config-files

ks-dashboards-configmap:
	-kubectl create configmap dashboards-config-files --from-file=opensearch/dashboards/configs

ks-dashboards-configmap-down:
	-kubectl delete configmap dashboards-config-files

ks-jaeger-collector:
	cd jaeger/collector; kubectl apply -f .

ks-jaeger-collector-down:
	-cd jaeger/collector; kubectl delete -f .

ks-jaeger-agent:
	cd jaeger/agent; kubectl apply -f .

ks-jaeger-agent-down:
	-cd jaeger/agent; kubectl delete -f .

ks-observability-down:
	$(MAKE) ks-fluent-bit-down
	$(MAKE) ks-fluent-bit-configmap-down
	$(MAKE) ks-data-prepper-down
	$(MAKE) ks-data-prepper-configmap-down
	$(MAKE) ks-dashboards-down
	$(MAKE) ks-dashboards-configmap-down
	$(MAKE) ks-opensearch-down
	$(MAKE) ks-opensearch-configmap-down

ks-opensearch-init-indexes:
	./opensearch/opensearch/scripts/init_indexes.sh

ks-dashboards-init-index-patterns:
	./opensearch/dashboards/scripts/config_index_patterns.sh


