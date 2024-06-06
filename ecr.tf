locals {
  ecr-lifecycle-policy = {
    rules = [
      {
        action = {
          type = "expire"
        }
        description  = "最新のイメージを5つだけ残す"
        rulePriority = 1
        selection = {
          countNumber = 5
          countType   = "imageCountMoreThan"
          tagStatus   = "any"
        }
      },
    ]
  }
}

resource "aws_ecr_repository" "corporate_container" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "corporate-container"
}

resource "aws_ecr_lifecycle_policy" "corporate_container_policy" {
  repository = aws_ecr_repository.corporate_container.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}