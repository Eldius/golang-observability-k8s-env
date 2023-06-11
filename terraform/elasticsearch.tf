#provider "elasticsearch" {
#    insecure = true
#    healthcheck = false
#    # username = "admin"
#    # password = "admin"
#    elasticsearch_version = "1.9.0"
#}
#
#resource "elasticsearch_xpack_index_lifecycle_policy" "test" {
#  name = "test"
#  body = <<EOF
#{
#  "policy": {
#    "phases": {
#      "hot": {
#        "min_age": "0ms",
#        "actions": {
#          "rollover": {
#            "max_size": "1gb"
#          }
#        }
#      }
#    }
#  }
#}
#EOF
#}
#
#resource "elasticsearch_index_template" "test" {
#  name = "test"
#  body = <<EOF
#{
#  "index_patterns": [
#    "test-*"
#  ],
#  "settings": {
#    "index": {
#      "lifecycle": {
#        "name": "${elasticsearch_xpack_index_lifecycle_policy.test.name}",
#        "rollover_alias": "test"
#      }
#    }
#  }
#}
#EOF
#}
#
#resource "elasticsearch_index" "test" {
#  name               = "test-000001"
#  number_of_shards   = 1
#  number_of_replicas = 1
#  aliases = jsonencode({
#    "test" = {
#      "is_write_index" = true
#    }
#  })
#
#  depends_on = [elasticsearch_index_template.test]
#}
