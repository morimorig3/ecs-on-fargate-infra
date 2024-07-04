variable "domain_name" {
  description = "ホストゾーンを作成するドメイン名"
  type        = string
}

variable "ecr_production_repository_name" {
  description = "作成するリポジトリ名"
  type        = string
}
