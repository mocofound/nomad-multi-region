# Terraform variables (all are required)
name =                    "nomad-mr"
key_name                  = "ahar-keypair-2024"
#ami                       = "ami-06926444eaf4bc839"
region_1                    = "us-east-1"
region_2                    = "us-east-2"
nomad_consul_token_id       = "ed85f52a-dd24-4c54-a2f5-9fbccfee1464"
nomad_consul_token_secret   = "5679b6b0-9e81-11ed-a8fc-0242ac120002"
cidr_block_region_1         = "172.11.0.0/16"
cidr_block_region_2         = "172.22.0.0/16"
#nomad_license_path             = "/opt/nomad/nomad-license.hclic" 
#consul_license_path            = "/opt/consul/consul-license.hclic" 


# These variables will default to the values shown
# and do not need to be updated unless you want to
# change them
# allowlist_ip            = "0.0.0.0/0"
# name                    = "nomad"
# server_instance_type    = "t2.micro"
# server_count            = "3"
# client_instance_type    = "t2.micro"
# client_count            = "3"