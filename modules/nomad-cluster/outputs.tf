output "lb_address_consul_nomad" {
  value = "${aws_instance.server[0].public_ip}"
}

output "consul_bootstrap_token_secret" {
  value = var.nomad_consul_token_secret
}

output "IP_Addresses" {
  value = <<CONFIGURATION

#Client public IPs: ${join(", ", aws_instance.client[*].public_ip)}

Server public IPs: ${join(", ", aws_instance.server[*].public_ip)}

The Consul UI can be accessed at http://${aws_instance.server[0].public_ip}:8500/ui
with the bootstrap token: ${var.nomad_consul_token_secret}
CONFIGURATION
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "transit_gateway" {
  value = aws_ec2_transit_gateway.tgw
}

output "nlb_dns" {
  value = aws_lb.nomad_client_nlb.dns_name
}

output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}

output "client_subnets" {
  value = toset(aws_subnet.private[*].id)
}