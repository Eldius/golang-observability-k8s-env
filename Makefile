
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

ks-observability-down-opensearch:
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

ks-setup-opensearch: ks-observability-down-opensearch

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

# ks-uptrace-clickhouse-configmap: ks-uptrace-clickhouse-configmap-down
# 	kubectl create configmap uptrace-clickhouse-config-files --from-file=uptrace/clickhouse/config

# ks-uptrace-clickhouse-configmap-down:
# 	-kubectl delete configmap uptrace-clickhouse-config-files

# ks-uptrace-clickhouse:
# 	cd uptrace/clickhouse; kubectl apply -f .

# ks-uptrace-clickhouse-down:
# 	cd uptrace/clickhouse; kubectl delete -f .

ks-skywalking:
	cd skywalking/backend; kubectl apply -f .

ks-skywalking-down:
	cd skywalking/backend; kubectl delete -f .


up:
	$(MAKE) ks-setup-opensearch

down:
	$(MAKE) ks-observability-down-opensearch


# test:
# 	# docker run -it --rm --name jdk -v temp:/data openjdk:17 keytool -h
# 	docker \
# 		run \
# 		-it \
# 		--rm \
# 		--name jdk \
# 		-v $(PWD)/.truststore:/data \
# 		-v $(PWD)/opensearch/data-prepper/configs/root-ca.pem:/certificate/root-ca.pem:ro \
# 		 openjdk:17-alpine \
# 		'apk add --update openssl && openssl x509 -outform der -in /certificate/root-ca.pem -out /data/certificate.der && keytool -genkey -alias bmc -keyalg RSA -keystore /data/KeyStore.jks -keysize 2048 && -import -file /data/certificate.der -keystore /data/KeyStore.jks'
# 	ls -lha temp

# .truststore/KeyStore.jks:
test:
	docker \
		run \
		-it \
		--rm \
		--name jdk \
		-v $(PWD)/.truststore:/data \
		-v $(PWD)/opensearch/data-prepper/configs/root-ca.pem:/certificate/root-ca.pem:ro \
		-v $(PWD)/skywalking/opensearch_certificate.sh:/opensearch_certificate.sh:ro \
		--entrypoint /opensearch_certificate.sh \
		 openjdk:17-alpine
