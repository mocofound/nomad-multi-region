# data "aws_vpc" "default" {
#   default = true
# }

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true


  tags = {
    Name = "${var.name}-${var.region}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-rt"
  }
}

resource "aws_subnet" "main" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.name}_subnet_${count.index}"
  }
  
  depends_on = []
}


resource "aws_security_group" "consul_nomad_ui_ingress" {
  name   = "${var.name}-ui-ingress"
  vpc_id = aws_vpc.main.id
  

  # Nomad
  ingress {
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    cidr_blocks     = [var.allowlist_ip]
  }

  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = [var.allowlist_ip]
  }

    # Java
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = [var.allowlist_ip]
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
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
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
  vpc_id = aws_vpc.main.id

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
  vpc_id = aws_vpc.main.id

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

