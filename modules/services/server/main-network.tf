locals {
  all_ip             = "0.0.0.0/0"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
}

# -----------------------------------------
# VPC
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
# Internet Gateway
# -----------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-internet-gateway"
  }
}

# -----------------------------------------
# Subnets
# -----------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  count                   = length(local.availability_zones)
  availability_zone       = local.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.this.id
  count                   = length(local.availability_zones)
  availability_zone       = local.availability_zones[count.index]
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 128)
  map_public_ip_on_launch = false

  tags = {
    name = "${var.environment}-private-subnet-${local.availability_zones[count.index]}"
  }
}

# -----------------------------------------
# Route Table
# -----------------------------------------
// Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    name = "${var.environment}-public-route-table"
  }
}
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = local.all_ip
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

// Private
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

module "vpc_security_group" {
  source     = "../../security_group"
  name       = "ecs-sg"
  vpc_id     = aws_vpc.this.id
  port       = 80
  cidr_block = local.all_ip
}

# -----------------------------------------
# VPC Endpoints
# -----------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = length(aws_subnet.private)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private[count.index].id
}

resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }
}
