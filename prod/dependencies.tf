data "aws_route53_zone" "this" {
  name = var.domain_name
}

data "aws_ecr_repository" "this" {
  name = var.repository_name
}
