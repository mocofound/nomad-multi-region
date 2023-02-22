data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
datacenter = "DATA_CENTER"
region = "DATA_CENTER"

# Enable the server
server {
  enabled          = true
  bootstrap_expect = SERVER_COUNT
  license_path = "NOMAD_LICENSE_PATH"
}

consul {
  address = "127.0.0.1:8500"
  token = "CONSUL_TOKEN"
}

#acl {
#  enabled = true
#}

vault {
  enabled          = false
  address          = "http://active.vault.service.consul:8200"
  task_token_ttl   = "1h"
  create_from_role = "nomad-cluster"
  token            = ""
}