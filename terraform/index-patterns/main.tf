
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
  # url="https://192.168.0.196:9200"
  username="admin"
  password="admin"
  insecure = true
}