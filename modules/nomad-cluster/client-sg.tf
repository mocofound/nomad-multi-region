resource "aws_security_group" "client_lb" {
  name   = "${var.name}-client-lb"
  #vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.vpc.id
  vpc_id = aws_vpc.vpc.id
  

  # Webapp HTTP.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  #TODO Postgres
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana metrics dashboard.
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  # Prometheus dashboard.
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  ingress {
    from_port   = 9292
    to_port     = 9292
    protocol    = "tcp"
    #cidr_blocks = var.allowlist_ip
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27115
    to_port     = 27115
    protocol    = "tcp"
    #cidr_blocks = var.allowlist_ip
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Traefik Router.
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
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
