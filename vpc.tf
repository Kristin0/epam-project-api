resource "aws_vpc" "epam-project" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "epam-project-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  vpc_id = aws_vpc.epam-project.id
  cidr_block = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "web,api-gateway"
  }
}


resource "aws_internet_gateway" "epam-igw" {
  vpc_id = aws_vpc.epam-project.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.epam-project.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.epam-igw.id
  }
}

resource "aws_route_table_association" "associate" {
  count = length(var.public_subnets)
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[count.index].id
}