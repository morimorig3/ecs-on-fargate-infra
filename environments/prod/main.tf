locals {
  environment = "prod"
}

terraform {
  required_version = "~> 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  // TODO: backend tfstate stateファイルをS3に保存する
}


provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Environment = local.environment
    }
  }
}

module "server" {
  source      = "../../modules/services/server"
  environment = local.environment
}
