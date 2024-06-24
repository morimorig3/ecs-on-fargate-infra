output "repository_url" {
  description = "作成されたECRレポジトリのURL"
  value       = aws_ecr_repository.this.repository_url
}
