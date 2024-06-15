terraform {
  required_version = "~> 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  // stateファイルをS3に保存する
  # backend "s3" {
  #   bucket         = "corporate-terraform-backend-bucket" # S3バケット名    
  #   key            = "terraform.tfstate"                  # S3バケット内のファイル名
  #   region         = "ap-northeast-1"                     # S3バケットのリージョン
  #   dynamodb_table = "TerraformLockTable"                 # stateをlockする設定。誰かがterraformを実行しているときは、他の人がterraformを実行できないようにする。
  # }
}

provider "aws" {
  region = "ap-northeast-1"

  # START: for LocalStack Settings 
  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true
  # s3_force_path_style         = true

  # endpoints {
  #   s3         = "http://localhost:4566"
  #   ecs        = "http://localhost:4566"
  #   iam        = "http://localhost:4566"
  #   cloudfront = "http://localhost:4566"
  #   route53    = "http://localhost:4566"
  # }
  # END: for LocalStack Settings 
}
