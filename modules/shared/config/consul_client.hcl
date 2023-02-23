ui = true
log_level = "INFO"
data_dir = "/opt/consul/data"
license_path = "CONSUL_LICENSE_PATH"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "IP_ADDRESS"
retry_join = ["RETRY_JOIN"]
datacenter = "DATA_CENTER"
recursors = ["172.21.0.2","172.22.0.2"]
#recursors = ["RECURSOR"]

acl {
    enabled = true
    default_policy = "deny"
    down_policy = "extend-cache"
    tokens {
      default = "CONSUL_TOKEN"
      agent = "CONSUL_TOKEN"
    }
}

connect {
  enabled = true
}

ports {
  grpc = 8502
}