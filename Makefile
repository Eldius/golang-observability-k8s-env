
CLUSTER_IP := 192.168.100.196

CONNECTION_TIMEOUT := 30
READ_TIMEOUT := 30

ks-observability-namespace-down:
	-kubectl delete namespace observability

ks-observability-namespace:
	-kubectl create namespace observability

ks-opensearch: ks-opensearch-configmap
	kubectl apply -f opensearch/opensearch

ks-opensearch-configmap: ks-opensearch-configmap-down
	-kubectl create configmap -n observability opensearch-certs --from-file=opensearch/opensearch/certs

ks-opensearch-configmap-down:
	-kubectl delete configmap opensearch-certs

ks-dashboards:
	cd opensearch/dashboards; kubectl apply -f .

opensearch-up:
	./scripts/is_opensearch_up.sh

ks-dashboards-down:
	-kubectl delete -f opensearch/dashboards

ks-data-prepper:
	kubectl apply -f opensearch/data-prepper

ks-data-prepper-down: ks-data-prepper-configmap-down
	-kubectl delete -f opensearch/data-prepper

ks-fluent-bit: ks-fluent-bit-configmap
	kubectl apply -f opensearch/fluent-bit

ks-postgres-configmap: ks-postgres-configmap-down
	-kubectl create configmap -n observability postgres-init-scripts --from-file=postgres/scripts

ks-postgres-configmap-down:
	-kubectl delete configmap postgres-init-scripts

ks-postgres: ks-postgres-down ks-postgres-configmap
	cd postgres; kubectl apply -f .

ks-postgres-down:
	-cd postgres; kubectl delete -f .

ks-fluent-bit-down: ks-fluent-bit-configmap-down
	-cd opensearch/fluent-bit; kubectl delete -f .

ks-opensearch-down:
	-cd opensearch/opensearch; kubectl delete -f .

ks-data-prepper-configmap:
	-kubectl create configmap -n observability data-prepper-config-files --from-file=opensearch/data-prepper/configs

ks-data-prepper-configmap-down:
	-kubectl delete configmap -n observability data-prepper-config-files

ks-fluent-bit-configmap:
	-kubectl create configmap -n observability fluent-bit-config-files --from-file=opensearch/fluent-bit/configs

ks-fluent-bit-configmap-down:
	-kubectl delete configmap -n observability fluent-bit-config-files

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
	$(MAKE) ks-collector-down
	$(MAKE) ks-collector-configmap-down
	$(MAKE) ks-skywalking-down
	$(MAKE) ks-skywalking-configmap-down
	$(MAKE) ks-collector-down
	$(MAKE) ks-data-prepper-down
	$(MAKE) ks-data-prepper-configmap-down
	$(MAKE) ks-dashboards-down
	$(MAKE) ks-opensearch-down
	$(MAKE) ks-opensearch-configmap-down
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

ks-wait-opensearch-startup:
	$(eval OPENSEARCH_IP := $(shell ./fetch_ports.sh opensearch 9200 observability))
	@echo "[before] opensearch => $(OPENSEARCH_IP)"

	until curl --fail -i --insecure -XGET https://$(shell ./fetch_ports.sh opensearch 9200 observability)/_cluster/health -u 'admin:admin' | grep -E '("status":"yellow"|"status":"green")'; do sleep 1; done

	$(eval OPENSEARCH_IP := $(shell ./fetch_ports.sh opensearch 9200 observability))
	@echo "[after]  opensearch => $(OPENSEARCH_IP)"
	@echo "Opensearch up and running"

ks-wait-dashboards-startup:
	$(eval OPENSEARCH_DASHBOARDS_IP := $(shell ./fetch_ports.sh opensearch-dashboards 5601 observability))
	@echo "[before] opensearch dashboards => $(OPENSEARCH_DASHBOARDS_IP)"

	until curl -i --fail -XGET 'http://$(shell ./fetch_ports.sh opensearch-dashboards 5601 observability)/app/home' -u 'admin:admin' -s -o /dev/null; do sleep 1; done

	$(eval OPENSEARCH_DASHBOARDS_IP := $(shell ./fetch_ports.sh opensearch-dashboards 5601 observability))
	@echo "[after]  opensearch dashboards => $(OPENSEARCH_DASHBOARDS_IP)"
	@echo "Dashboards up and running"

ks-wait-data-prepper-startup:
	$(eval DATA_PREPPER_IP := $(shell ./fetch_ports.sh data-prepper 2021 observability))
	@echo "[before] data prepper => $(DATA_PREPPER_IP)"

	until curl -i --fail -XGET 'http://$(shell ./fetch_ports.sh data-prepper 2021 observability)/health' -s -o /dev/null; do sleep 1; done

	$(eval DATA_PREPPER_IP := $(shell ./fetch_ports.sh data-prepper 2021 observability))
	@echo "[after]  data prepper => $(DATA_PREPPER_IP)"
	@echo "Data Prepper up and running"

ks-wait-fluent-bit-startup:
	$(eval FLUENTBIT_IP := $(shell ./fetch_ports.sh fluent-bit 24220 observability))
	@echo "[before] fluent bit => $(FLUENTBIT_IP)"

	until curl -i --fail -XGET 'http://$(shell ./fetch_ports.sh fluent-bit 24220 observability)/' -s -o /dev/null; do sleep 1; done

	$(eval FLUENTBIT_IP := $(shell ./fetch_ports.sh fluent-bit 24220 observability))
	@echo "[after]  fluent bit => $(FLUENTBIT_IP)"
	@echo "FluentBit up and running"

ks-setup-opensearch: ks-observability-down-opensearch ks-observability-namespace

	@echo "-----"
	@echo "Creating Opensearch configmap"
	@echo "-----"
	@echo ""
	$(MAKE) ks-opensearch-configmap
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

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


	@echo "-----"
	@echo "Creating Skywalking OAP configmap"
	@echo "-----"
	@echo ""
	$(MAKE) ks-skywalking-configmap
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating Skywalking OAP"
	@echo "-----"
	@echo ""
	$(MAKE) ks-skywalking
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting Skywalking OAP startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-skywalking-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating OTEL Collector configmap"
	@echo "-----"
	@echo ""
	$(MAKE) ks-collector-configmap
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Creating OTEL Collector"
	@echo "-----"
	@echo ""
	$(MAKE) ks-collector
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

	@echo "-----"
	@echo "Waiting OTEL Collector startup"
	@echo "-----"
	@echo ""
	$(MAKE) ks-wait-collector-startup
	@echo ""
	@echo "*****"
	@echo ""
	@echo ""
	@echo ""

terraform-opensearch-log-indexes:
	$(eval OPENSEARCH_HOST := $(shell ./fetch_ports.sh opensearch 9200 observability))
	@echo "Opensearch Host: $(OPENSEARCH_HOST)"
	cd terraform/log-indexes; OPENSEARCH_URL="https://$(OPENSEARCH_HOST)" terraform init
	cd terraform/log-indexes; OPENSEARCH_URL="https://$(OPENSEARCH_HOST)" terraform apply -auto-approve

terraform-dashboards-log-patterns:
	$(eval OPENSEARCH_HOST := $(shell ./fetch_ports.sh opensearch 9200 observability))
	@echo "Opensearch Host: $(OPENSEARCH_HOST)"
	cd terraform/index-patterns; OPENSEARCH_URL="https://$(OPENSEARCH_HOST)" terraform init
	cd terraform/index-patterns; OPENSEARCH_URL="https://$(OPENSEARCH_HOST)" terraform apply -auto-approve

# ks-uptrace-clickhouse-configmap: ks-uptrace-clickhouse-configmap-down
# 	kubectl create configmap -n observability uptrace-clickhouse-config-files --from-file=uptrace/clickhouse/config

# ks-uptrace-clickhouse-configmap-down:
# 	-kubectl delete configmap uptrace-clickhouse-config-files

# ks-uptrace-clickhouse:
# 	cd uptrace/clickhouse; kubectl apply -f .

# ks-uptrace-clickhouse-down:
# 	cd uptrace/clickhouse; kubectl delete -f .

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

clear-certs-temp-folder:
	-rm -rf .truststore

opensearch-certs: clear-certs-temp-folder
	$(eval USER_ID := $(shell id -u $(USER)))
	docker \
		run \
		-it \
		--rm \
		--name jdk \
		-v $(PWD)/.truststore:/data \
		-e "USER_ID=$(USER_ID)" \
		-v $(PWD)/skywalking/opensearch_certificate.test.sh:/opensearch_certificate.sh:ro \
		--entrypoint /opensearch_certificate.sh \
		 openjdk:17-alpine
	cp -v $(PWD)/.truststore/* $(PWD)/opensearch/opensearch/certs


skywalking-truststore: clear-certs-temp-folder
	$(eval USER_ID := $(shell id -u $(USER)))
	docker \
		run \
		-it \
		--rm \
		--name jdk \
		-v $(PWD)/.truststore:/data \
		-v $(PWD)/opensearch/opensearch/certs/root-ca.pem:/certificate/root-ca.pem:ro \
		-v $(PWD)/opensearch/opensearch/certs/node1.pem:/certificate/node1.pem:ro \
		-v $(PWD)/opensearch/opensearch/certs/client.pem:/certificate/client.pem:ro \
		-v $(PWD)/skywalking/opensearch_certificate.sh:/opensearch_certificate.sh:ro \
		-e "USER_ID=$(USER_ID)" \
		--entrypoint /opensearch_certificate.sh \
		 openjdk:17-alpine
	cp -v $(PWD)/.truststore/KeyStore.jks $(PWD)/skywalking/backend/config


test:
	$(eval USER_ID := $(shell id -u $(USER)))
	docker \
		run \
		-it \
		--rm \
		--name jdk \
		-v $(PWD)/.truststore:/data \
		-v $(PWD)/opensearch/opensearch/certs/root-ca.pem:/certificate/root-ca.pem:ro \
		-v $(PWD)/opensearch/opensearch/certs/node1.pem:/certificate/node1.pem:ro \
		-v $(PWD)/opensearch/opensearch/certs/client.pem:/certificate/client.pem:ro \
		-v $(PWD)/skywalking/opensearch_certificate.sh:/opensearch_certificate.sh:ro \
		-e "USER_ID=$(USER_ID)" \
		 openjdk:17-alpine ash


fetch_ports:
	$(eval POSTGRES_IP := $(shell ./fetch_ports.sh POSTGRES 5432))
	@echo "opensearch => $(POSTGRES_IP)"


ks-skywalking: ks-skywalking-configmap
	kubectl apply -f skywalking/backend

ks-skywalking-down: ks-skywalking-configmap-down
	-kubectl delete -f skywalking/backend

ks-skywalkingui:
	kubectl apply -f skywalking/frontend

ks-skywalkingui-down:
	-kubectl delete -f skywalking/frontend

ks-collector: ks-collector-configmap
	kubectl apply -f skywalking/collector

ks-collector-down: ks-collector-configmap
	-kubectl delete -f skywalking/collector

ks-skywalking-configmap: ks-skywalking-configmap-down
	-kubectl create configmap -n observability skywalking-config-files --from-file=skywalking/backend/config

ks-skywalking-configmap-down:
	-kubectl delete configmap -n observability skywalking-config-files

ks-collector-configmap: ks-collector-configmap-down
	-kubectl create configmap -n observability collector-config-files --from-file=skywalking/collector/config

ks-collector-configmap-down:
	-kubectl delete configmap -n observability collector-config-files

ks-wait-collector-startup:
	$(eval SKYWALKING_IP := $(shell ./fetch_ports.sh otel-collector 13133 observability))
	@echo "[before] opensearch => $(SKYWALKING_IP)"
	until curl --fail -i --insecure -XGET http://$(shell ./fetch_ports.sh otel-collector 13133 observability)/health/status; do sleep 1; done
	$(eval SKYWALKING_IP := $(shell ./fetch_ports.sh otel-collector 13133 observability))
	@echo "[after]  opensearch => $(SKYWALKING_IP)"
	@echo "OTEL Collector up and running"

ks-wait-skywalking-startup:
	$(eval SKYWALKING_IP := $(shell ./fetch_ports.sh skywalking 11800 observability))
	@echo "[before] skywalking => $(SKYWALKING_IP)"
	until grpcurl -plaintext -proto skywalking/backend/config/healthcheck.proto -connect-timeout $(CONNECTION_TIMEOUT) -max-time $(READ_TIMEOUT) $(shell ./fetch_ports.sh skywalking 11800 observability) grpc.health.v1.Health.Check; do echo "still waiting"; sleep 1; done
	$(eval SKYWALKING_IP := $(shell ./fetch_ports.sh skywalking 11800 observability))
	@echo "[after]  skywalking => $(SKYWALKING_IP)"
	@echo "Skywalking up and running"

cluster-install:
	ansible-playbook -i cluster/ansible/env/ ansible/cluster/master.yaml
	ansible-playbook -i cluster/ansible/env/ ansible/cluster/worker_nodes.yaml

nodes-setup: cluster-install
	kubectl label nodes eksnode0 kubernetes.io/role=worker
	kubectl label nodes eksnode1 kubernetes.io/role=worker
	kubectl label nodes eksnode0 node-type=worker
	kubectl label nodes eksnode1 node-type=worker
	ansible -i cluster/ansible/env master -b -m lineinfile -a "path='/etc/environment' line='KUBECONFIG=/etc/rancher/k3s/k3s.yaml'"

cluster-uninstall:
	ansible-playbook -i cluster/ansible/env/ ansible/cluster/master_uninstall.yaml

cluster-tests:
	ansible-playbook -i cluster/ansible/env/ ansible/cluster/testing.yaml

metallb-setup:
	helm repo add metallb https://metallb.github.io/metallb
	helm search repo metallb
	helm upgrade \
		--install metallb \
		metallb/metallb \
		--create-namespace \
		--namespace metallb-system \
		--wait
	kubectl apply -f cluster/metallb/resources.yaml

storage-setup:
	ansible-playbook -i cluster/ansible/env cluster/ansible/storage.yaml
	helm repo add longhorn https://charts.longhorn.io
	helm repo update
	helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/storage01"
	kubectl apply -f cluster/longhornui/service.yaml

cluster-setup: nodes-setup metallb-setup storage-setup

up:
	$(MAKE) ks-setup-opensearch

down:
	$(MAKE) ks-observability-down-opensearch
