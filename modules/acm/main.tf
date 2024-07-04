terraform {
  required_version = "~> 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "provider"
  region = var.region
}

resource "aws_acm_certificate" "this" {
  provider          = aws.provider
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ACMのDNS検証用レコードの生成
resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  zone_id         = var.route53_zone_id
  ttl             = 60

  depends_on = [aws_acm_certificate.this]
}

# ACMのDNS検証用レコードのチェック
resource "aws_acm_certificate_validation" "this" {
  provider                = aws.provider
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = flatten([values(aws_route53_record.this)[*].fqdn])

  depends_on = [aws_acm_certificate.this, aws_route53_record.this]
}
