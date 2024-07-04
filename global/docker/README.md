# ECRリポジトリへDockerイメージをアップロードする

公式から引用

## 前提

AWS CLIとDockerがインストールされていること

## CLIでAWSへ繋げるように認証する

```
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```
※AWS_ACCOUNT_IDは実行環境のものに置き換える

## Dockerイメージを作成する

任意の方法でDockerイメージを作成する

```
docker build -t {REPOSITORY_NAME} .
```

## イメージをECRにプッシュできるようにタグ付け

```
docker tag {REPOSITORY_NAME}:latest {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/{REPOSITORY_NAME}:latest
```


## PUSH

```
docker push {AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/{REPOSITORY_NAME}:latest
```