resource "aws_cloudwatch_event_bus" "ecommerce" {
  name = "serverless-ecommerce-event-bus"
}

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "serverless-ecommerce-order-created"
  event_bus_name = aws_cloudwatch_event_bus.ecommerce.name

  event_pattern = jsonencode({
    source = ["serverless-ecommerce"]
    detail = {
      eventType = ["OrderCreated"]
    }
  })
}

resource "aws_sqs_queue" "order_processing" {
  name = "serverless-ecommerce-order-processing"
}

resource "aws_cloudwatch_event_target" "order_created_sqs" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.ecommerce.name
  arn            = aws_sqs_queue.order_processing.arn
}

resource "aws_sqs_queue_policy" "order_processing" {
  queue_url = aws_sqs_queue.order_processing.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.order_processing.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.order_created.arn
          }
        }
      }
    ]
  })
}