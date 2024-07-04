variable "domain_name" {
  description = "ドメイン名"
  type        = string
}

variable "route53_zone_id" {
  description = "ホストゾーンID"
  type        = string
}

variable "region" {
  description = "リージョン"
  type        = string
}
