data_dir = "/opt/consul/data"
license_path = "CONSUL_LICENSE_PATH"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "IP_ADDRESS"
datacenter = "DATA_CENTER"
#recursors = ["RECURSOR"]
recursors = ["172.21.0.2","172.22.0.2"]
bootstrap_expect = SERVER_COUNT

acl {
    enabled = true
    default_policy = "deny"
    down_policy = "extend-cache"
    enable_token_persistence = true
    tokens {
      default = "CONSUL_TOKEN"
      #agent = "CONSUL_TOKEN"
    }
}

log_level = "INFO"

server = true
ui = true
retry_join = ["RETRY_JOIN"]

service {
    name = "consul"
}

connect {
  enabled = true
}

ports {
  grpc = 8502
}