
terraform {
  required_providers {
    elasticsearch = {
      source = "phillbaker/elasticsearch"
      #version = "2.0.7"
    }
    opensearch = {
      source = "opensearch-project/opensearch"
      #version = "2.0.0"
    }
  }

}

provider "opensearch" {
  # Configuration options
  url="https://192.168.100.195:9200"
  username="admin"
  password="admin"
  insecure = true
}

# Create a simple index
resource "opensearch_index" "logs" {
  name               = "application-logs-00001"
  number_of_shards   = 1
  number_of_replicas = 0
  mappings           = file("${path.module}/mappings/log-index.json")
}
