
k3s-install:
	ansible-playbook -i ansible/env/ ansible/k3s_master_install.yaml
	ansible-playbook -i ansible/env/ ansible/k3s_workers_install.yaml
	ansible -i ansible/env master -b -m lineinfile -a "path='/etc/environment' line='KUBECONFIG=/etc/rancher/k3s/k3s.yaml'"
	sftp eldius@192.168.0.59:/etc/rancher/k3s/k3s.yaml ~/.kube/config
	kubectl label nodes k8snode0 kubernetes.io/role=worker
	kubectl label nodes k8snode1 kubernetes.io/role=worker
	kubectl label nodes k8snode2 kubernetes.io/role=worker
	kubectl label nodes k8snode0 node-type=worker
	kubectl label nodes k8snode1 node-type=worker
	kubectl label nodes k8snode2 node-type=worker

k3s-uninstall:
	ansible-playbook -i ansible/env/ ansible/k3s_uninstall.yaml

k3s-tests:
	ansible-playbook -i ansible/env/ ansible/testing.yaml

cluster-network: metallb-install metallb-config
	@echo "MetallB Installed..."

metallb-install:
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

metallb-config:
	kubectl apply -f metallb/resources.yaml

metallb-uninstall:
	-kubectl delete -f metallb/resources.yaml
	kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

storage-install:
	ansible-playbook -i ansible/env ansible/storage.yaml
	helm repo add longhorn https://charts.longhorn.io
	helm repo update
	helm install \
		longhorn \
		longhorn/longhorn \
		--namespace longhorn-system \
		--create-namespace --set defaultSettings.defaultDataPath="/storage01"
	kubectl apply -f longhornui/service.yaml

storage-uninstall:
	-kubectl delete -f longhornui/service.yaml
	helm uninstall \
		longhorn \
		--namespace longhorn-system

storage-tests:
	ansible-playbook -i ansible/env ansible/storage.yaml

# cluster-setup: nodes-setup metallb-setup storage-setup

# cluster-setup: k3s-install metallb-uninstall

cluster-setup: k3s-install storage-install metallb-install

ping-hosts:
	# ansible -i ansible/env cube -a "uname -a"
	ansible -i ansible/env/ all -m ping -v

# testing:
# 	kubectl delete -f testing

test-ansible:
	ansible-playbook -i ansible/env ansible/testing.yaml
