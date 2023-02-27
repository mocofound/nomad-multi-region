data "aws_caller_identity" "current" {}
module "nomad_cluster_region_1" {
    source = "./modules/nomad-cluster"
    providers = {
       aws = aws 
       }
    name                      = var.name
    key_name                  = var.key_name
    #ami                       = "ami-06926444eaf4bc839"
    region                    = var.region_1
    availability_zones        = ["${var.region_1}a","${var.region_1}b","${var.region_1}c"]
    nomad_consul_token_id     = var.nomad_consul_token_id
    nomad_consul_token_secret = var.nomad_consul_token_secret
    vpc_cidr_block            = var.cidr_block_region_1
    subnet                    = var.subnet_region_1
    recursor                  = var.recursor_region_1
}

module "nomad_cluster_region_2" {
    source = "./modules/nomad-cluster"
    providers = {
       aws = aws.region2
       }
    name                      = var.name
    key_name                  = var.key_name
    #ami                       = "ami-06926444eaf4bc839"
    region                    = var.region_2
    availability_zones        = ["${var.region_2}a","${var.region_2}b","${var.region_2}c"]
    nomad_consul_token_id     = var.nomad_consul_token_id
    nomad_consul_token_secret = var.nomad_consul_token_secret
    vpc_cidr_block            = var.cidr_block_region_2
    subnet                    = var.subnet_region_2
    recursor                  = var.recursor_region_2
}


# # Requester's side of the connection.
# resource "aws_vpc_peering_connection" "peer" {
#   vpc_id        = "${module.nomad_cluster_region_1.vpc_id}"
#   peer_vpc_id   = "${module.nomad_cluster_region_2.vpc_id}"
#   peer_owner_id = "${data.aws_caller_identity.current.account_id}"
#   peer_region   = "${var.region_2}"
#   #auto_accept   = false
#   #auto_accept =  true
#   requester {
#     allow_remote_vpc_dns_resolution = true
#   }
#   tags = {
#     Side = "Requester"
#   }
#   depends_on = [
#     module.nomad_cluster_region_1,
#     module.nomad_cluster_region_2,
#   ]
# }

# # Accepter's side of the connection.
# resource "aws_vpc_peering_connection_accepter" "peer" {
#   provider                  = aws.region2
#   vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
#   auto_accept               = true
#   accepter {
#     allow_remote_vpc_dns_resolution = true
#   }
#   tags = {
#     Side = "Accepter"
#   }
#   depends_on = [
#     module.nomad_cluster_region_1,
#     module.nomad_cluster_region_2,
#   ]
# }       