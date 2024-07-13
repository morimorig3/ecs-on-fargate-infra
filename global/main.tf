terraform {
  required_version = "~> 1.8.0"

  # NOTE: 初回applyをしてS3を作成してからコメントアウトを外す ※README参照
  backend "s3" {
    bucket         = "bita-corporate-terraform-state"
    key            = "global/terraform.state"
    region         = "ap-northeast-1"
    dynamodb_table = "bita-corporate-terraform-locks"
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
}

# ホストゾーンは破壊されないようにglobalで作成
module "route53_host_zone" {
  source      = "../modules/route53_host_zone"
  domain_name = var.domain_name
}

module "ecr_production" {
  source                        = "../modules/ecr"
  repository_name               = var.ecr_production_repository_name
  lifecycle_policy_description  = "最新のイメージを5つだけ残す"
  lifecycle_policy_count_number = 5
}
