resource "aws_iam_role" "worker_lambda_role" {
  name = "serverless-ecommerce-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_lambda_basic_execution" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "worker_lambda_sqs" {
  name = "serverless-ecommerce-worker-sqs"
  role = aws_iam_role.worker_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.order_processing.arn
      }
    ]
  })
}

data "archive_file" "worker_lambda" {
  type        = "zip"
  source_file = "${path.module}/../application/lambda/worker.py"
  output_path = "${path.module}/worker_lambda.zip"
}

resource "aws_lambda_function" "order_worker" {
  function_name = "serverless-ecommerce-order-worker"

  filename         = data.archive_file.worker_lambda.output_path
  source_code_hash = data.archive_file.worker_lambda.output_base64sha256

  role    = aws_iam_role.worker_lambda_role.arn
  handler = "worker.lambda_handler"
  runtime = "python3.12"

  timeout = 30
}

resource "aws_lambda_event_source_mapping" "order_processing" {
  event_source_arn = aws_sqs_queue.order_processing.arn
  function_name    = aws_lambda_function.order_worker.arn

  batch_size = 1
}