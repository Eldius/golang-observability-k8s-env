
resource "opensearch_dashboard_object" "logs_index_pattern" {
  body = file("${path.module}/patterns/log-index-pattern.json")
}
