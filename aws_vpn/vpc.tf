# data "aws_availability_zones" "current" {}

resource "aws_vpc" "vpn_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "vpn_vpc"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.subnet_public_cidrs)
  vpc_id            = aws_vpc.vpn_vpc.id
  cidr_block        = var.subnet_public_cidrs[count.index]
  availability_zone = var.subnet_public_az[count.index]

  # tags = {
  #   Name = var.subnet_public_names[count.index]
  # }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpn_vpc.id

  tags = {
    Name = "VPN gateway"
  }
}

resource "aws_route_table" "vpn_pub_rt" {
  vpc_id = aws_vpc.vpn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "VPN public RT"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnet_public_cidrs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.vpn_pub_rt.id
}
