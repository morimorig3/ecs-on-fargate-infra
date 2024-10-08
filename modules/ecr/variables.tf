variable "repository_name" {
  description = "作成するリポジトリ名"
  type        = string
}

variable "lifecycle_policy_description" {
  description = "ライフサイクルポリシーの説明"
  type        = string
}

variable "lifecycle_policy_count_number" {
  description = "リポジトリに保持するイメージの最大数"
  type        = number
}
