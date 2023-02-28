# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${module.nomad_cluster_region_1[0].vpc_id}"
  peer_vpc_id   = "${module.nomad_cluster_region_2[0].vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_region   = "${var.region_2}"
#   accepter {
#     allow_remote_vpc_dns_resolution = true
#   }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Side = "Requester"
  }
  depends_on = [
    module.nomad_cluster_region_1[0],
    module.nomad_cluster_region_2[0],
  ]
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.region2
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Side = "Accepter"
  }
  depends_on = [
    module.nomad_cluster_region_1[0],
    module.nomad_cluster_region_2[0],
  ]
}       

# resource "aws_route_table" "peer_region_1_to_2" {
#   #count = length(aws_subnet.private)
#   vpc_id = module.nomad_cluster_region_1[0].vpc_id

#   route {
#     cidr_block = var.cidr_block_region_2
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "${var.name}-rt-vpcpeer"
#   }
# }

# resource "aws_route_table" "peer_region_2_to_1" {
#   #count = length(aws_subnet.private)
#   vpc_id = module.nomad_cluster_region_2[0].vpc_id

#   route {
#     cidr_block = var.cidr_block_region_1
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }

#   tags = {
#     Name = "${var.name}-rt-vpcpeer2"
#   }
# }