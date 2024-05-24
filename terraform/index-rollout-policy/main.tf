
terraform {
  required_providers {
    # elasticsearch = {
    #   source = "phillbaker/elasticsearch"
    #   #version = "2.0.7"
    # }
    opensearch = {
      source = "opensearch-project/opensearch"
      # version = "2.2.0"
    }
  }

}

provider "opensearch" {
  # Configuration options
  # url      = "https://192.168.0.196:9200"
  username = "admin"
  password = "admin"
  insecure = true
}

resource "opensearch_ism_policy" "logs_cleanup_policy" {
  policy_id = "default_logs_delete_after_1d"
  body      = file("${path.module}/policy/default_delete_after_1d.json")
}
