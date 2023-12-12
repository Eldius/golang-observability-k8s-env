
CLUSTER_IP := 192.168.100.196

ks-opensearch:
	cd opensearch/opensearch; kubectl apply -f .

ks-dashboards:
	cd opensearch/dashboards; kubectl apply -f .

opensearch-up:
	./scripts/is_opensearch_up.sh

ks-dashboards-down:
	-cd opensearch/dashboards; kubectl delete -f .

ks-data-prepper:
	cd opensearch/data-prepper; kubectl apply -f .

ks-data-prepper-down: ks-data-prepper-configmap-down
	-cd opensearch/data-prepper; kubectl delete -f .

ks-fluent-bit:
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

ks-jaeger-collector:
	cd jaeger/collector; kubectl apply -f .

ks-jaeger-collector-down:
	-cd jaeger/collector; kubectl delete -f .

ks-jaeger-agent:
	cd jaeger/agent; kubectl apply -f .

ks-jaeger-agent-down:
	-cd jaeger/agent; kubectl delete -f .

ks-observability-down:
	@echo "-----"
	@echo "Destroying infraestructure"
	@echo "-----"
	@echo ""
	$(MAKE) ks-fluent-bit-down
	$(MAKE) ks-fluent-bit-configmap-down
	$(MAKE) ks-data-prepper-down
	$(MAKE) ks-data-prepper-configmap-down
	$(MAKE) ks-dashboards-down
	$(MAKE) ks-opensearch-down
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

ks-wait-opensearch-startup:
	until curl --fail -i --insecure -XGET https://$(CLUSTER_IP):9200/_cluster/health -u 'admin:admin' | grep -E '("status":"yellow"|"status":"green")'; do sleep 1; done
	@echo "Opensearch up and running"

ks-wait-dashboards-startup:
	until curl -i --fail -XGET 'http://$(CLUSTER_IP):5601/app/home' -u 'admin:admin' -s -o /dev/null; do sleep 1; done
	@echo "Dashboards up and running"

ks-wait-data-prepper-startup:
	until curl -i --fail -XGET 'http://$(CLUSTER_IP):2021/health' -s -o /dev/null; do sleep 1; done
	@echo "Data Prepper up and running"

ks-wait-fluent-bit-startup:
	until curl -i --fail -XGET 'http://$(CLUSTER_IP):24220/' -s -o /dev/null; do sleep 1; done
	@echo "FluentBit up and running"

ks-setup: ks-observability-down

	@echo "-----"
	@echo "Creating Opensearch"
	@echo "-----"
	@echo ""
	$(MAKE) ks-opensearch
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Opensearch startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-opensearch-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Running Opensearch indexes Terraform script"
	@echo "-----"
	@echo ""
	$(MAKE) terraform-opensearch-log-indexes
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating Dashboards"
	@echo "-----"
	@echo ""
	$(MAKE) ks-dashboards
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Dashboards startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-dashboards-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Dashboards startup"
	@echo "-----"
	@echo ""
	$(MAKE) terraform-dashboards-log-patterns
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Dashboards startup"
	@echo "-----"
	@echo ""
	$(MAKE) terraform-dashboards-log-patterns
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating Data Prepper configmap"
	@echo "-----"
	@echo ""
	$(MAKE) ks-data-prepper-configmap
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating Data Prepper"
	@echo "-----"
	@echo ""
	$(MAKE) ks-data-prepper
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Data Prepper startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-data-prepper-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating FluentBit configmap"
	@echo "-----"
	@echo ""
	$(MAKE) ks-fluent-bit-configmap
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating FluentBit"
	@echo "-----"
	@echo ""
	$(MAKE) ks-fluent-bit
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting FluentBit startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-fluent-bit-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""


terraform-opensearch-log-indexes:
	cd terraform/log-indexes; terraform init
	cd terraform/log-indexes; terraform apply -auto-approve

terraform-dashboards-log-patterns:
	cd terraform/index-patterns; terraform init
	cd terraform/index-patterns; terraform apply -auto-approve

up:
	$(MAKE) ks-setup

down:
	$(MAKE) ks-observability-down
