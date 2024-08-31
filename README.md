# コーポレートサイト AWS　- Terraform

## 命名規則
- corporate-production: 本番環境用のリソースにつけるプレフィックス
- corporate-staging: プレビュー用のリソースにつけるプレフィックス

## 構築手順

### tfstate管理用S3の作成

#### 保存用S3の作成

```
cd global
terraform init
terraform apply -auto-approve
```

### コードのコメントアウト

```
# main.tf
backend "s3" {
    bucket         = "morimorig3-corporate-terraform-state"
    key            = "global/terraform.state"
    region         = "ap-northeast-1"
    dynamodb_table = "morimorig3-corporate-terraform-locks"
    encrypt        = true
}
```

### ステートファイルをS3へ保存するように変更する

```
terraform init
Do you want to copy existing state to the new backend? -> yes
```

### 動作確認

```
terraform state list
```

### 資材のリリース

tfstate管理用S3の作成が完了していること

```
cd prod
terraform init
terraform apply -auto-approve
```

## 開発関連

### lintの手動実行

```
pre-commit run -a
```