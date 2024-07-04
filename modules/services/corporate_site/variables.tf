variable "aws_account_id" {
  type = string
}

variable "environment" {
  description = "バケット名やリソース名に使用するプレフィックス"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  type        = string
}

# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "fargate_cpu" {
  description = "FargateのCPUスペック"
  type        = string
}

# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "fargate_memory" {
  description = "Fargateのメモリスペック"
  type        = string
}

variable "repository_name" {
  description = "ECRのリポジトリ名"
  type        = string
}

variable "domain_name" {
  description = "ドメイン名"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53ホストゾーンID"
  type        = string
}

variable "route53_zone_name" {
  description = "Route53ホストゾーン名"
  type        = string
}

variable "certificate_arn_tokyo" {
  description = "ACMで発行した証明書のarn"
  type        = string
}

variable "certificate_arn_virginia" {
  description = "ACMで発行した証明書のarn"
  type        = string
}
