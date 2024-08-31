terraform {
  required_version = "~> 1.8.0"

  backend "s3" {
    bucket         = "morimorig3-corporate-terraform-state"
    key            = "prod/terraform.state"
    region         = "ap-northeast-1"
    dynamodb_table = "morimorig3-corporate-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Environment = "production"
    }
  }
}

module "acm_alb" {
  source          = "../modules/acm"
  domain_name     = data.aws_route53_zone.this.name
  route53_zone_id = data.aws_route53_zone.this.zone_id
  region          = "ap-northeast-1"
}

// cloudfront用のACMはバージニアリージョンで作成する必要がある
module "acm_cloudfront" {
  source          = "../modules/acm"
  domain_name     = data.aws_route53_zone.this.name
  route53_zone_id = data.aws_route53_zone.this.zone_id
  region          = "us-east-1"
}

module "corporate_site" {
  source                   = "../modules/services/corporate_site"
  environment              = "production"
  vpc_cidr_block           = "10.0.0.0/16"
  fargate_cpu              = "256"
  fargate_memory           = "512"
  aws_account_id           = var.aws_account_id
  domain_name              = var.domain_name
  certificate_arn_tokyo    = module.acm_alb.arn
  certificate_arn_virginia = module.acm_cloudfront.arn
  route53_zone_id          = data.aws_route53_zone.this.id
  route53_zone_name        = data.aws_route53_zone.this.name
  repository_name          = data.aws_ecr_repository.this.name
}
