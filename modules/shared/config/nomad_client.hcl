data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
datacenter = "DATA_CENTER"
region = "DATA_CENTER"

# Enable the client
client {
  enabled = true
  options {
    "driver.raw_exec.enable"    = "1"
    "docker.privileged.enabled" = "true"
  }
  artifact {
    disable_filesystem_isolation = true
  }
}

server_join {
  retry_join = [ "provider=aws tag_key=ConsulAutoJoin tag_value=autojoin" ]
}

acl {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"
  token = "CONSUL_TOKEN"
}

vault {
  enabled = true
  address = "http://active.vault.service.consul:8200"
}