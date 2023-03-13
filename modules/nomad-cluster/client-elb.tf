resource "aws_elb" "nomad_client" {
  name               = "${var.name}-nomad-client"
  #availability_zones = toset(data.aws_availability_zones.available.names)
  subnets            = toset(aws_subnet.private[*].id)
  #availability_zones = var.availability_zones
  
  internal           = false
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
#   listener {
#     instance_port     = 9090
#     instance_protocol = "http"
#     lb_port           = 9090
#     lb_protocol       = "http"
#   }
  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 8081
    instance_protocol = "http"
    lb_port           = 8081
    lb_protocol       = "http"
  }
#TODO
  health_check {
    healthy_threshold   = 8
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 30
  }
#TODO
  #security_groups = [aws_security_group.client_lb.id]
  depends_on = [
    aws_internet_gateway.private,
    aws_instance.server[0],
    aws_nat_gateway.public[0]
  ]
}