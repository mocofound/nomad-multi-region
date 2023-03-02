resource "aws_security_group" "consul_nomad_ui_ingress" {
  name   = "${var.name}-ui-ingress"
  vpc_id = aws_vpc.vpc.id

  # Nomad
  ingress {
    from_port       = 4646
    to_port         = 4648
    protocol        = "tcp"
    cidr_blocks     = var.allowlist_ip
    #security_groups = 
  }
  ingress {
    from_port       = 4646
    to_port         = 4648
    protocol        = "tcp"
    security_groups = [aws_security_group.client_lb.id,aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]
  }

  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = var.allowlist_ip
  }

    # Java
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = var.allowlist_ip
  }

# #TODO
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     self      = true
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_ingress" {
  name   = "${var.name}-ssh-ingress"
  vpc_id = aws_vpc.vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowlist_ip
  }

  # ingress {
  #   from_port = 0
  #   to_port   = 0
  #   protocol  = "-1"
  #   self      = true
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all_internal" {
  name   = "${var.name}-allow-all-internal"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
#TODO
  # ingress {
  #   from_port = 0
  #   to_port   = 0
  #   protocol  = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "clients_ingress" {
  name   = "${var.name}-clients-ingress"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
