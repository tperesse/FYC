provider "aws" {
  region                  = "eu-west-3"
  shared_credentials_file = "/home/theo/.aws/credentials"
  profile                 = "default"
}

###
# VPC.
###
resource "aws_vpc" "projet_annuel" {
  cidr_block = "10.0.0.0/16"
}

###
# Elastic Public IP.
###
resource "aws_eip" "eip" {
  vpc = true
}

###
# Subnets.
###
resource "aws_subnet" "public1" {
    vpc_id                  = aws_vpc.projet_annuel.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "eu-west-3a"
    map_public_ip_on_launch = true
    tags              = {Name = "Public_1"}
}

resource "aws_subnet" "public2" {
    vpc_id            = aws_vpc.projet_annuel.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "eu-west-3b"
    map_public_ip_on_launch = true
    tags              = {Name = "Public_2"}
}

resource "aws_subnet" "private1" {
    vpc_id            = aws_vpc.projet_annuel.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "eu-west-3a"
    tags              = {Name = "Private_1"}
}

resource "aws_subnet" "private2" {
    vpc_id            = aws_vpc.projet_annuel.id
    cidr_block        = "10.0.3.0/24"
    availability_zone = "eu-west-3b"
    tags              = {Name = "Private_2"}
}

###
# Internet gateway.
###
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.projet_annuel.id
    tags   = {Name = "IGW"}
}

###
# NAT gateway.
###
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.public1.id
    tags          = {Name = "NAT_GW"}
}

###
# Private route table.
###
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.projet_annuel.id
    tags   = {Name = "Private_route"}
}

resource "aws_route" "private_route" {
    route_table_id         = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "private_association1" {
    subnet_id      = aws_subnet.private1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_association2" {
    subnet_id      = aws_subnet.private2.id
    route_table_id = aws_route_table.private_route_table.id
}

###
# Public route table.
###
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.projet_annuel.id
    tags   = {Name = "Public_route"}
}

resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_association1" {
    subnet_id      = aws_subnet.public1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association2" {
    subnet_id      = aws_subnet.public2.id
    route_table_id = aws_route_table.public_route_table.id
}