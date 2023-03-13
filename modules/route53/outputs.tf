output "lb_dns_region_1" {
  value = aws_route53_record.dr.fqdn
}

output "lb_dns_region_2" {
  value = aws_route53_record.primary.fqdn
}