data "aws_caller_identity" "current" {}

locals {
  create_region_1 = true
  create_region_2 = true
  create_route53  = true
  use_hcp_packer = true
  tde_oracle     = true
  allowlist_ip    = [var.cidr_block_region_1, var.cidr_block_region_2, "23.120.120.157/32"]
  ###
  # Modify the below values to simulate a failover
  ###
  prod_client_count = 10
  run_nomad_jobs_region_1  = local.declare_disaster == false ? true : false
  asg_client_count_region_1 = local.declare_disaster == false ? local.prod_client_count : 0
  run_nomad_jobs_region_2  = local.declare_disaster == true ? true : false
  asg_client_count_region_2 = local.declare_disaster == true ? local.prod_client_count : 0
  declare_disaster = false
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
    recursor                  = var.recursor_region_1
    allowlist_ip              = local.allowlist_ip
    use_hcp_packer            = local.use_hcp_packer
    asg_client_count          = local.asg_client_count_region_1
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
    recursor                  = var.recursor_region_2
    allowlist_ip              = local.allowlist_ip
    use_hcp_packer            = local.use_hcp_packer
    asg_client_count          = local.asg_client_count_region_2
}


module "nomad_jobs_region_1" {
  count = local.run_nomad_jobs_region_1 ? 1 : 0
  source = "./modules/nomad-jobs"
  nomad_addr = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:4646"
  depends_on = [
    module.nomad_cluster_region_1
  ]
}

module "nomad_jobs_region_2" {
  count = local.run_nomad_jobs_region_2 ? 1 : 0
  providers = {
    nomad = nomad.region2
   }
  source = "./modules/nomad-jobs"
  nomad_addr = "http://${module.nomad_cluster_region_2[0].lb_address_consul_nomad}:4646"
  depends_on = [
    module.nomad_cluster_region_2
  ]
}

module "route53" {
  count = local.create_route53 ? 1 : 0
  source = "./modules/route53"
  #nomad_addr = "http://${module.nomad_cluster_region_1[0].lb_address_consul_nomad}:4646"
  domain_name = var.domain_name
  lb_dns_region_1 = ["${module.nomad_cluster_region_1[0].nlb_dns}"]
  lb_dns_region_2 = ["${module.nomad_cluster_region_2[0].nlb_dns}"]
}

module "tde_oracle" {
    count = local.tde_oracle ? 1 : 0
    source = "./modules/tde-oracle"
    providers = {
       #aws = aws
       }
    depends_on = [
      module.nomad_cluster_region_1
    ]
}

# module "nomad_config" {
#     count = local.configure_nomad ? 1 : 0
#     source = "./modules/nomad-config"
#     providers = {
#        nomad = nomad
#        }
#     depends_on = [
#       module.nomad_cluster_region_1
#     ]
# }
