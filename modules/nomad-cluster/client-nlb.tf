variable "ports" {
  type    = map(number)
  default = {
    http  = 80
    https = 443
    java = 9090
    java-hello = 9292
    java-dynamic = 27115
    ssh   = 22
    nomad = 4646
  }
}

resource "aws_security_group" "nomad_client_nlb" {
  description = "Allow connection between NLB and target"
  name = "${var.name}-nomad-client-nlb"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "nomad_client_nlb" {
  for_each = var.ports

  security_group_id = aws_security_group.nomad_client_nlb.id
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  type              = "ingress"
  
  #cidr_blocks       = [var.allowlist_ip, "0.0.0.0/0"]
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nomad_client_nlb_egress" {
  security_group_id = aws_security_group.nomad_client_nlb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_lb_target_group" "nomad_client" {
  for_each = var.ports
  name = "${var.name}-${each.key}-nlb-target"
  port        = each.value
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
  preserve_client_ip = true
  depends_on = [
    aws_lb.nomad_client_nlb
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "nomad_client" {
  for_each = var.ports

  autoscaling_group_name = aws_autoscaling_group.nomad_client.name
  lb_target_group_arn   = aws_lb_target_group.nomad_client[each.key].arn
}

# resource "aws_lb_target_group_attachment" "name" {
  
# }

# resource "aws_eip" "nlb" {
#   vpc = true
# }

resource "aws_lb" "nomad_client_nlb" {
  name               = "${var.name}-client-nlb-eip-5"
  load_balancer_type = "network"
  subnets            = toset(aws_subnet.private[*].id)
  internal = true
  #security_groups = [aws_security_group.nomad_client_nlb.id]
  enable_cross_zone_load_balancing = true
    # subnet_mapping {
    #     subnet_id = aws_subnet.private[0].id
    #     allocation_id = aws_eip.natgw[0].allocation_id
    # }
    #     subnet_mapping {
    #     subnet_id = aws_subnet.private[1].id
    #     allocation_id = aws_eip.natgw[1].allocation_id
    # }
    # subnet_mapping {
    #     subnet_id = aws_subnet.private[2].id
    #     allocation_id = aws_eip.nlb.allocation_id
    # }

# dynamic "subnet_mapping" {

#     for_each = { for key, value in variable.instance_types:
#                    key => {
#                       subnet_id = value.subnet_id
#                    } if value.role == "control-plane"  
#                }

#     content {
#       subnet_id            = subnet_mapping.value.subnet_id
#       private_ipv4_address = aws_instance.k8s-node[subnet_mapping.key].private_ip
#     }
    
# }

}

resource "aws_lb_listener" "nomad_client" {
  for_each = var.ports
  
  load_balancer_arn = aws_lb.nomad_client_nlb.arn

  protocol          = "TCP"
  port              = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_client[each.key].arn
  }
}

