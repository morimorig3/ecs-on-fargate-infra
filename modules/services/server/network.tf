# -----------------------------------------
# VPC (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
# -----------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true      # AWS の DNS サーバーによる名前解決を有効にする
  enable_dns_hostnames = true      # VPC 内のリソースにパブリック DNS ホスト名を自動的に割り当てる
  instance_tenancy     = "default" # VPC内インスタンスのテナント属性を指定

  tags = {
    name = "corporate-${var.environment}-vpc"
  }
}

# -----------------------------------------
# Public Network
# -----------------------------------------
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/24" // TODO: 切り方検討
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24" // TODO: 切り方検討
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-1c"
  }
}

# -----------------------------------------
# Internet Gateway
# -----------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# -----------------------------------------
# Public Route Table
# -----------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    name = "${var.environment}-public-route-table"
  }
}

// Route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

// Route Table Association
resource "aws_route_table_association" "public_route_table_association_1a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1a.id
}

resource "aws_route_table_association" "public_route_table_association_1c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1c.id
}

# -----------------------------------------
# Private Network
# -----------------------------------------
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.128.0/24" // TODO: 切り方検討
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    name = "${var.environment}-private-subnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.129.0/24" // TODO: 切り方検討
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    name = "${var.environment}-private-subnet-1c"
  }
}

# Route Table
resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}-private-route-table-1a"
  }
}
resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.environment}-private-route-table-1c"
  }
}

# Route
resource "aws_route" "private_1a" {
  route_table_id         = aws_route_table.private_1a.id
  nat_gateway_id         = aws_nat_gateway.nat_1a.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_1c" {
  route_table_id         = aws_route_table.private_1c.id
  nat_gateway_id         = aws_nat_gateway.nat_1c.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route Table Association
resource "aws_route_table_association" "private_1a" {
  route_table_id = aws_route_table.private_1a.id
  subnet_id      = aws_subnet.private_1a.id
}

resource "aws_route_table_association" "private_c" {
  route_table_id = aws_route_table.private_1c.id
  subnet_id      = aws_subnet.private_1c.id
}

# -----------------------------------------
# Elastic IP Address
# -----------------------------------------
resource "aws_eip" "nat_1a" {
  depends_on = [aws_internet_gateway.this]
  tags = {
    Name = "${var.environment}-eip-1a"
  }
}
resource "aws_eip" "nat_1c" {
  depends_on = [aws_internet_gateway.this]
  tags = {
    Name = "${var.environment}-eip-1c"
  }
}

# -----------------------------------------
# Nat Gateway これは消すかも
# -----------------------------------------
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.private_1a.id
  depends_on    = [aws_internet_gateway.this]
  tags = {
    Name = "${var.environment}-nat-gw-1a"
  }
}
resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.private_1c.id
  depends_on    = [aws_internet_gateway.this]
  tags = {
    Name = "${var.environment}-nat-gw-1c"
  }
}

module "vpc_security_group" {
  source     = "../../security_group"
  name       = "ecs-sg"
  vpc_id     = aws_vpc.this.id
  port       = 80
  cidr_block = "0.0.0.0/0"
}
