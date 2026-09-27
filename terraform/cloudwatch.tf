resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
  name           = "serverless-ecommerce-lambda-errors"
  log_group_name = "/aws/lambda/serverless-ecommerce-get-products"
  pattern        = "ERROR"

  metric_transformation {
    name      = "ServerlessEcommerceLambdaErrors"
    namespace = "ServerlessEcommerce"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "serverless-ecommerce-lambda-errors"
  alarm_description   = "Alert when the ecommerce Lambda reports errors"
  namespace           = "ServerlessEcommerce"
  metric_name         = "ServerlessEcommerceLambdaErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]
}
