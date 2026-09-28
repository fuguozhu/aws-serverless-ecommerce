terraform {
  backend "s3" {
    bucket       = "serverless-ecommerce-tfstate-498623467710"
    key          = "terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
