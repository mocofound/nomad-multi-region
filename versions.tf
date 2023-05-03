#https://www.devopsschool.com/blog/terraform-variable-map-type-explained/

terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1"
    # }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
            configuration_aliases = [ aws.region1 , aws.region2 ]
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 1.4.19"
    }
    hcp = {
      source  = "hashicorp/hcp"
      #version = "~> 1.4.0"
    }
  }
}

provider "aws" {
  region = var.region_1
}

provider "aws" {
  alias = "region2"
  region = var.region_2
}

provider "nomad" {
  region = var.region_1
  address = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:4646"
  secret_id = "${file("nomad-${var.region_1}.token")}"
}

provider "nomad" {
  alias = "region2"
  region = var.region_2
  address = "http://${module.nomad_cluster_region_2[0].lb_address_consul_nomad}:4646"
  secret_id = "${file("nomad-${var.region_2}.token")}"
}


# data "local_file" "nomad_token_region_1" {
#   filename = "${path.module}/files/grafana_dashboard.json"
# }
