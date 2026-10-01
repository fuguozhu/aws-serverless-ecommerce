resource "aws_s3_bucket" "frontend" {
  bucket = "serverless-ecommerce-frontend-498623467710"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
data "aws_iam_policy_document" "frontend" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend.json
}

resource "aws_s3_object" "frontend_config" {
  bucket = aws_s3_bucket.frontend.id
  key    = "config.js"

  content = templatefile(
    "${path.module}/../application/frontend/config.js.tftpl",
    {
      api_url           = aws_apigatewayv2_stage.default.invoke_url
      cognito_client_id = aws_cognito_user_pool_client.web.id
      aws_region        = var.aws_region
    }
  )

  content_type = "application/javascript"

  cache_control = "no-cache"
}
resource "aws_s3_object" "frontend_index" {
  bucket = aws_s3_bucket.frontend.id
  key    = "index.html"

  source = "${path.module}/../application/frontend/index.html"

  content_type = "text/html"

  cache_control = "no-cache"
}