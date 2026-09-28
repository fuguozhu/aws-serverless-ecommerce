# AWS Serverless EC注文・在庫管理システム

AWSのサーバーレスサービスを利用して構築した、EC注文・在庫管理システムです。

## 概要

商品の取得・注文処理・在庫管理・認証・非同期処理・通知・監視までをAWS上で実装しています。

Infrastructure as CodeにはTerraform、CI/CDにはGitHub 
Actionsを使用しています。

## アーキテクチャ

```text
                    GitHub
                       │
                       ▼
               GitHub Actions
                       │
                  OIDC / IAM
                       │
                       ▼
                  Terraform
                       │
        ┌──────────────┴──────────────┐
        │                             │
   API Gateway                   EventBridge
        │                             │
        ▼                             ▼
      Lambda                         SQS
        │                             │
   ┌────┴────┐                        ▼
   │         │                     Lambda
   ▼         ▼                        │
DynamoDB   Cognito                    │
Products   認証                       │
Orders                                │
                                      ▼
                                    SNS
                                      │
                                  通知・監視
```

## 主な機能

* 商品一覧・商品情報の取得
* 商品注文
* DynamoDBによる在庫管理
* Cognitoによるユーザー認証
* API GatewayによるJWT認証
* EventBridgeによるイベント連携
* SQSによる非同期注文処理
* Lambda Workerによる注文処理
* 在庫が少なくなった場合のSNS通知
* CloudWatchによるエラー監視・アラーム

## 使用技術

### AWS

* API Gateway
* Lambda
* DynamoDB
* Cognito
* EventBridge
* SQS
* SNS
* CloudWatch
* IAM

### 開発・運用

* Python
* Terraform
* GitHub Actions
* GitHub OIDC

## CI/CD

GitHubへのPushをトリガーとしてGitHub Actionsを実行します。

```text
GitHub Push
    ↓
GitHub Actions
    ↓
OIDC認証
    ↓
AWS IAM Role
    ↓
Terraform
    ↓
Init → Format Check → Validate → Plan
```

AWSアクセスキーをGitHubに保存せず、OIDCを利用してAWS IAM 
Roleを引き受ける構成にしています。

## 学習・実装ポイント

* AWSサーバーレスアーキテクチャ
* イベント駆動アーキテクチャ
* 非同期処理
* AWS IAM / OIDC
* Infrastructure as Code
* GitHub ActionsによるCI/CD
* CloudWatchによる監視

## Repository

GitHub:
https://github.com/fuguozhu/aws-serverless-ecommerce

