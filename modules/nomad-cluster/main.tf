# data "aws_vpc" "default" {
#   default = true
# }

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-${var.region}-vpc"
  }
}

resource "aws_nat_gateway" "public" {
  count = "${length(aws_subnet.public)}" 
  #connectivity_type = "private"
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[count.index].id
  allocation_id = aws_eip.natgw[count.index].id
  tags = {
    Name = "${var.name}-${var.region}-ngw-eip"
  }
}

resource "aws_eip" "natgw" {
  count = "${length(aws_subnet.public)}" 
  vpc = true

  tags = {
    Name = "${var.name}-${var.region}-ngw-eip"
  }
}

resource "aws_internet_gateway" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private"
  }
}

resource "aws_default_route_table" "private" {
  #count = length(aws_subnet.private)
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private.id
    #gateway_id = aws_nat_gateway.private[count.index].id
  }

  tags = {
    Name = "${var.name}-default-rt"
  }
}

resource "aws_route_table" "private" {
  count = "${length(aws_subnet.private)}" 
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[count.index].id
    #gateway_id = aws_nat_gateway.private.id
  }

  tags = {
    Name = "${var.name}-rt-private"
  }
}

resource "aws_route_table" "public" {
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private.id
  }

  tags = {
    Name = "${var.name}-rt-public"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(aws_subnet.private)}" 
  subnet_id      =  aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      =  aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.name}_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 100)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.name}_public_subnet_${count.index}"
  }
  
  depends_on = [aws_vpc.vpc]
}