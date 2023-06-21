resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.app_name}-${terraform.workspace}-vpc"
    env  = "${terraform.workspace}"
  }
}

resource "aws_subnet" "pub-snet" {
  vpc_id                  = aws_vpc.vpc.id
  for_each                = var.pub-snet-details
  cidr_block              = each.value["cidr_block"]
  availability_zone       = each.value["availability_zone"]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${terraform.workspace}-pub-snet"
    env  = "${terraform.workspace}"
  }
}

resource "aws_subnet" "pri-snet" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.pri-snet-details
  cidr_block        = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = {
    Name = "${var.app_name}-${terraform.workspace}-pri-snet"
    env  = "${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-${terraform.workspace}-igw"
    env  = "${terraform.workspace}"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${terraform.workspace}-pub-rt"
    env  = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "rt-association" {
  for_each       = aws_subnet.pub-snet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub-rt.id
}