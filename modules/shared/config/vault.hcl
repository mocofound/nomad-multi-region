ui = true
license_path="VAULT_LICENSE_PATH"
storage "raft" {
  path = "/opt/vault/raft"
}
cluster_addr = "http://127.0.0.1:8201"
api_addr = "http://127.0.0.1:8200"

seal "awskms" {
  region     = "REGION"
  kms_key_id = "KMS_KEY"
}
listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "IP_ADDRESS:8201"
  tls_disable     = 1
}

service_registration "consul" {
  address      = "http://127.0.0.1:8500"
  token = "CONSUL_TOKEN"
}
