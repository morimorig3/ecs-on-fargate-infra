terraform {
  required_version = "~> 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ecr_lifecycle_policy_document" "this" {
  rule {
    action {
      type = "expire"
    }
    priority    = 1
    description = var.lifecycle_policy_description
    selection {
      count_number = var.lifecycle_policy_count_number
      count_type   = "imageCountMoreThan"
      tag_status   = "any"
    }
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_ecr_lifecycle_policy_document.this.json
}
