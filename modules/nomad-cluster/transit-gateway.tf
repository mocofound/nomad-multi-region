resource "aws_ec2_transit_gateway" "tgw" {
  tags = {
    Name = "${var.name}-tgw"
  }
}





# resource "aws_ec2_transit_gateway_route_table_association" "tgw" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw.id
# }


# resource "aws_ec2_transit_gateway_route_table" "tgw" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
# }

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  subnet_ids         = toset(aws_subnet.public[*].id)
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-vpc-attach"
  }
}