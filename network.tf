# -----------------------------------------
# VPC (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
# -----------------------------------------
resource "aws_vpc" "corporate-production-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true      # AWS の DNS サーバーによる名前解決を有効にする
  enable_dns_hostnames = true      # VPC 内のリソースにパブリック DNS ホスト名を自動的に割り当てる
  instance_tenancy     = "default" # VPC内インスタンスのテナント属性を指定

  tags = {
    name = "corporate-production-vpc"
  }
}

# -----------------------------------------
# Public Network
# -----------------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.corporate-production-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.corporate-production-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-c"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "corperate_gateway" {
  vpc_id = aws_vpc.corporate-production-vpc.id

  tags = {
    name = "ecs-gateway"
  }
}

// Route Table
resource "aws_route_table" "public_route_table" {

  vpc_id = aws_vpc.corporate-production-vpc.id

  tags = {
    name = "public-route-table"
  }
}

// Route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.corperate_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

// Route Table Association
resource "aws_route_table_association" "public_route_table_association_a" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_a.id
}

resource "aws_route_table_association" "public_route_table_association_c" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_c.id
}

# -----------------------------------------
# Private Network
# -----------------------------------------
resource "aws_subnet" "ecs_private_subnet_a" {
  vpc_id                  = aws_vpc.corporate-production-vpc.id
  cidr_block              = "10.0.128.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    name = "ecs_private_subnet_a"
  }
}

resource "aws_subnet" "ecs_private_subnet_c" {
  vpc_id                  = aws_vpc.corporate-production-vpc.id
  cidr_block              = "10.0.129.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    name = "ecs_private_subnet_c"
  }
}

# Route Table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.corporate-production-vpc.id
  tags = {
    Name = "private-route-table-a"
  }
}
resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.corporate-production-vpc.id
  tags = {
    Name = "private-route-table-c"
  }
}
# Route
resource "aws_route" "private_a" {
  route_table_id         = aws_route_table.private_a.id
  nat_gateway_id         = aws_nat_gateway.nat_a.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_c" {
  route_table_id         = aws_route_table.private_c.id
  nat_gateway_id         = aws_nat_gateway.nat_c.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route Table Association
resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private_a.id
  subnet_id      = aws_subnet.ecs_private_subnet_a.id
}

resource "aws_route_table_association" "private_c" {
  route_table_id = aws_route_table.private_c.id
  subnet_id      = aws_subnet.ecs_private_subnet_c.id
}

# Elastic IP Address
resource "aws_eip" "nat_a" {

  depends_on = [aws_internet_gateway.corperate_gateway]
  tags = {
    Name = "example-eip-a"
  }
}
resource "aws_eip" "nat_c" {

  depends_on = [aws_internet_gateway.corperate_gateway]
  tags = {
    Name = "example-eip-c"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.ecs_private_subnet_a.id
  depends_on    = [aws_internet_gateway.corperate_gateway]
  tags = {
    Name = "example-nat-gw-a"
  }
}
resource "aws_nat_gateway" "nat_c" {
  allocation_id = aws_eip.nat_c.id
  subnet_id     = aws_subnet.ecs_private_subnet_c.id
  depends_on    = [aws_internet_gateway.corperate_gateway]
  tags = {
    Name = "example-nat-gw-c"
  }
}

# ------------------------------------------------------

module "vpc_security_group" {
  source      = "./security_group"
  name        = "ecs-sg"
  vpc_id      = aws_vpc.corporate-production-vpc.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
