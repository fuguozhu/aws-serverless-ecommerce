# AWS Serverless EC注文・在庫管理システム

AWSのサーバーレスサービスを利用して構築した、EC注文・在庫管理システムです。

商品取得、ユーザー認証、注文・在庫管理、イベント駆動型の非同期処理、監視までを実装しています。

## Architecture

```text
                    GitHub
                       │
                 GitHub Actions
                  OIDC / Terraform
                       │
                       ▼
Browser ──→ CloudFront ──→ S3
  │
  └────→ API Gateway ──→ Lambda
                         │
                    ┌────┴────┐
                    ▼         ▼
                DynamoDB   EventBridge
                              │
                              ▼
                             SQS
                              │
                              ▼
                       Worker Lambda

Cognito ──→ API Gateway JWT Authentication

Lambda ──→ CloudWatch ──→ SNS
```

## Features

* 商品一覧・注文・在庫管理
* Cognitoによるユーザー認証
* API Gateway + LambdaによるAPI
* EventBridge + SQSによる非同期処理
* Lambda Workerによる注文後処理
* CloudWatchによるエラー監視
* SNSによる通知
* CloudFront + S3によるFrontend配信

## Tech Stack

**AWS**

* API Gateway
* Lambda
* DynamoDB
* Cognito
* EventBridge
* SQS
* SNS
* CloudWatch
* CloudFront
* S3
* IAM

**Development**

* Python
* Terraform
* GitHub Actions
* GitHub OIDC

## CI/CD

```text
GitHub Push
    ↓
GitHub Actions
    ↓
OIDC
    ↓
AWS IAM
    ↓
Terraform
    ↓
Plan → Apply
```

AWS Access KeyをGitHubに保存せず、OIDCによるIAM Role認証を使用しています。

## Project Structure

```text
application/
├── frontend/
└── lambda/

terraform/
├── *.tf

.github/
└── workflows/
    └── terraform.yml
```

