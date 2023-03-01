# Create the intra-region Peering Attachment from Gateway 1 to Gateway 2.
# Actually, this will create two peerings: one for Gateway 1 (Creator)
# and one for Gateway 2 (Acceptor).
resource "aws_ec2_transit_gateway_peering_attachment" "example_source_peering" {
  provider = aws
  peer_region             = var.region_2
  transit_gateway_id      = module.nomad_cluster_region_1[0].transit_gateway.id
  peer_transit_gateway_id = module.nomad_cluster_region_2[0].transit_gateway.id
  tags = {
    Name = "${var.name}-tgw-peering"
    Side = "Creator"
  }
  
}

# Transit Gateway 2's peering request needs to be accepted.
# So, we fetch the Peering Attachment that is created for the Gateway 2.
data "aws_ec2_transit_gateway_peering_attachment" "example_accepter_peering_data" {
  depends_on = [aws_ec2_transit_gateway_peering_attachment.example_source_peering]
  filter {
    name   = "transit-gateway-id"
    values = [module.nomad_cluster_region_1[0].transit_gateway.id]
  }
  filter {
    name   = "state"
    values = ["pendingAcceptance","available"]
  }
}

# Accept the Attachment Peering request.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "example_accepter" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.example_accepter_peering_data.id
  tags = {
    Name = "${var.name}-tgw-peering-accepter"
    Side = "Acceptor"
  }
  provider = aws.region2
}