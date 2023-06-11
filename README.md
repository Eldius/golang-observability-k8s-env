# pocs de observasbilidade k8s env #

Projeto para configuração do backend para testes com o projeto
[golang-observability-poc](github.com/Eldius/golang-observability-poc.git).

Decidi tentar configurar um cluster k8s numa Raspberry que tinha aqui de bobeira,
assim eu libero recursos na máquina local pra facilitar minha vida.


```shell
## colocar o conteudo abaixo no arquivo /boot/cmdline.txt
# cgroup_memory=1 cgroup_enable=memory
sudo vim /boot/cmdline.txt

## instalar o k3s
curl -sfL https://get.k3s.io | sh -

```

```shell
cat /etc/rancher/k3s/k3s.yaml

vim  ~/.kube/config
```

## opensearch validations ##

```bash
# opensearch

## healthchceck
curl --insecure -XGET https://192.168.100.195:9200/_cluster/health -u 'admin:admin' | jq .

## cat indexes
curl --insecure -i https://192.168.100.195:9200/_cat/indices?v -u 'admin:admin'

# dashboards
curl --insecure -XGET 'http://192.168.100.195:5601/api/saved_objects/_find?type=index-pattern&search_fields=title&search=*application*' -u 'admin:admin'

curl --insecure -XGET 'http://192.168.100.195:9200/custom-application-logs-00001' -u 'admin:admin'

```
