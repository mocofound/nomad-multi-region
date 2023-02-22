variable "name" {
  description = "Prefix used to name various infrastructure components. Alphanumeric characters only."
  default     = "nomad"
}

variable "region" {
  description = "The AWS region to deploy to."
}

variable "region_2" {
  description = "The second AWS region to deploy to."
  default = "us-east-2"
}

variable "availability_zones" {
  default = ["us-east-1a","us-east-1b","us-east-1c"]
} 

variable "ami" {
  description = "The AMI to use for the server and client machines. Output from the Packer build process."
  default = ""
}

variable "key_name" {
  description = "The name of the AWS SSH key to be loaded on the instance at provisioning."
}

variable "retry_join" {
  description = "Used by Consul to automatically form a cluster."
  type        = string
  default     = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

variable "allowlist_ip" {
  description = "IP to allow access for the security groups (set 0.0.0.0/0 for world)"
  default     = "0.0.0.0/0"
}

variable "server_instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t2.micro"
}

variable "client_instance_type" {
  description = "The AWS instance type to use for clients."
  default     = "t2.micro"
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "client_count" {
  description = "The number of clients to provision."
  default     = "0"
}

variable "asg_client_count" {
  description = "The number of clients to provision."
  default     = "3"
}

variable "root_block_device_size" {
  description = "The volume size of the root block device."
  default     = 16
}

variable "nomad_consul_token_id" {
  description = "Accessor ID for the Consul ACL token used by Nomad servers and clients. Must be a UUID."
}

variable "nomad_consul_token_secret" {
  description = "Secret ID for the Consul ACL token used by Nomad servers and clients. Must be a UUID."
}

variable "nomad_binary" {
  description = "URL of a zip file containing a nomad executable to replace the Nomad binaries in the AMI with. Example: https://releases.hashicorp.com/nomad/0.10.0/nomad_0.10.0_linux_amd64.zip"
  default     = ""
}

variable "nomad_license_path" {
  description = ""
  default     = "/etc/nomad.d/nomad-license.hclic"
}

variable "consul_license_path" {
  description = ""
  default     = "/etc/consul.d/consul-license.hclic"
}

variable "vpc_id" {
  default = ""
}

variable "nomad_autoscaler_image" {
  description = "The Docker image to use for the Nomad Autoscaler job."
  type        = string
  default     = "hashicorp/nomad-autoscaler:0.3.7"
}

variable "vpc_cidr_block" {
}

variable "subnet" {
}
