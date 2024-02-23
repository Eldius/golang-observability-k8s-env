
terraform {
  required_providers {
    # elasticsearch = {
    #   source = "phillbaker/elasticsearch"
    #   #version = "2.0.7"
    # }
    opensearch = {
      source = "opensearch-project/opensearch"
      version = "2.2.0"
    }
  }

}

provider "opensearch" {
  # Configuration options
  # url      = "https://192.168.100.196:9200"
  username = "admin"
  password = "admin"
  insecure = true
}

resource "opensearch_ism_policy" "logs_cleanup_policy" {
  policy_id = "default_delete_after_1d"
  body      = file("${path.module}/mappings/index_rollout_policy.json")
}

# Create a simple index
resource "opensearch_index" "logs" {
  depends_on = [ opensearch_ism_policy.logs_cleanup_policy ]
  name               = "application-logs-00001"
  number_of_shards   = 1
  number_of_replicas = 0

  aliases            = jsonencode({
    "application-logs" = {
      "is_write_index" = true
    }
  })
  mappings           = file("${path.module}/mappings/log-index.json")
  # mappings           = "{}"
}
