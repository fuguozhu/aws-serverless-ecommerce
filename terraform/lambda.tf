data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../application/lambda/main.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "get_products" {
  function_name = "serverless-ecommerce-get-products"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "main.lambda_handler"
  runtime = "python3.12"

  environment {
    variables = {
      PRODUCTS_TABLE       = aws_dynamodb_table.products.name
      ORDERS_TABLE         = aws_dynamodb_table.orders.name
      ORDER_EVENT_BUS_NAME = aws_cloudwatch_event_bus.ecommerce.name
    }
  }
}