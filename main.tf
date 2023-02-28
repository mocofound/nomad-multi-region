data "aws_caller_identity" "current" {}

locals {
  create_region_1 = true
  create_region_2 = true
  configure_nomad = true
  run_nomad_jobs  = false
  #allowlist_ip    = [var.cidr_block_region_1, var.cidr_block_region_2, "35.86.117.5/32","23.120.120.157/32","52.36.117.124/32","34.219.238.172/32","3.21.44.20/32","18.188.87.227/32","3.133.86.57/32"]
  allowlist_ip    = [var.cidr_block_region_1, var.cidr_block_region_2, "23.120.120.157/32"]
}

module "nomad_cluster_region_1" {
    count = local.create_region_1 ? 1 : 0
    source = "./modules/nomad-cluster"
    providers = {
       aws = aws 
       }
    name                      = var.name
    key_name                  = var.key_name
    region                    = var.region_1
    availability_zones        = ["${var.region_1}a","${var.region_1}b","${var.region_1}c"]
    nomad_consul_token_id     = var.nomad_consul_token_id
    nomad_consul_token_secret = var.nomad_consul_token_secret
    vpc_cidr_block            = var.cidr_block_region_1
    peer_vpc_cidr_block       = var.cidr_block_region_2
    #subnet                    = var.subnet_region_1
    #recursor                  = var.recursor_region_1
    allowlist_ip              = local.allowlist_ip
}

module "nomad_cluster_region_2" {
    count = local.create_region_2 ? 1 : 0
    source = "./modules/nomad-cluster"
    providers = {
       aws = aws.region2
       }
    name                      = var.name
    key_name                  = var.key_name
    region                    = var.region_2
    availability_zones        = ["${var.region_2}a","${var.region_2}b","${var.region_2}c"]
    nomad_consul_token_id     = var.nomad_consul_token_id
    nomad_consul_token_secret = var.nomad_consul_token_secret
    vpc_cidr_block            = var.cidr_block_region_2
    peer_vpc_cidr_block       = var.cidr_block_region_1
    #subnet                    = var.subnet_region_2
    #recursor                  = var.recursor_region_2
    allowlist_ip              = local.allowlist_ip
}

module "nomad_config" {
    count = local.configure_nomad ? 1 : 0
    source = "./modules/nomad-config"
    providers = {
       nomad = nomad
       }
    depends_on = [
      module.nomad_cluster_region_1
    ]
}

module "nomad_jobs_region_1" {
  count = local.run_nomad_jobs ? 1 : 0
  source = "./modules/nomad-jobs"
  nomad_addr = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:4646"
}

multiregion {

    strategy {
      max_parallel = 1
      on_failure   = "fail_all"
    }

    region "us-east-1" {
      count       = 1
      datacenters = ["us-east-1"]
    }

    region "us-east-2" {
      count       = 5
      datacenters = [ "us-east-2"]
    }

  }
