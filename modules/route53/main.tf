
data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}."
  private_zone = false
}


# resource "aws_route53_zone" "primary" {
#   name = var.domain_name
# }

resource "aws_route53_zone" "dr" {
  name = "dev.${var.domain_name}"

  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "dr" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dr"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "dr"
  records        = var.lb_dns_region_1
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "primary"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "primary"
  records        = var.lb_dns_region_2
}