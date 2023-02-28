
variable "region_1" {
  default = "us-east-1"
}

variable "region_2" {
  default = "us-east-2"
}

variable "cidr_block_region_1" {
  default = "172.21.0.0/16"
}

variable "cidr_block_region_2" {
  default = "172.22.0.0/16"
}

variable "subnet_region_1" {
  default = "172.21.0.0/24"
}

variable "subnet_region_2" {
  default = "172.22.0.0/24"
}

variable "recursor_region_1" {
  default = "172.21.0.2"
}

variable "recursor_region_2" {
  default = "172.22.0.2"
}

variable "name" {
  description = "Prefix used to name various infrastructure components. Alphanumeric characters only."
  default     = "nomad"
}

variable "nomad_consul_token_id" {
  description = "Accessor ID for the Consul ACL token used by Nomad servers and clients. Must be a UUID."
}

variable "nomad_consul_token_secret" {
  description = "Secret ID for the Consul ACL token used by Nomad servers and clients. Must be a UUID."
}

variable "key_name" {
  description = "The name of the AWS SSH key to be loaded on the instance at provisioning."
}
