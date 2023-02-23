resource "aws_security_group" "client_lb" {
  name   = "${var.name}-client-lb"
  #vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.main.id
  vpc_id = aws_vpc.main.id
  

  # Webapp HTTP.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

  # Grafana metrics dashboard.
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

  

  # Prometheus dashboard.
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

  # Traefik Router.
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

#TODO
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  
  #TODO
  ingress {
    from_port = 8300
    to_port   = 8301
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8300
    to_port   = 8301
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}