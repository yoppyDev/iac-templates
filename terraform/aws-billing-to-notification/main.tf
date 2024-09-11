provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Name = "aws-billing-to-slack-notification"
    }
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Archive
data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "build/layer"
  output_path = "lambda/layer.zip"
}
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "build/function"
  output_path = "lambda/function.zip"
}

# Layer
resource "aws_lambda_layer_version" "notify_lambda_layer" {
  layer_name       = "notify_lambda_layer"
  filename         = data.archive_file.layer_zip.output_path
  source_code_hash = data.archive_file.layer_zip.output_base64sha256
}

# Function
resource "aws_lambda_function" "notify" {
  function_name = "aws-billing-to-notification"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "lambda.main.handler"
  runtime       = "python3.9"
  timeout       = 20 // タイムアウトで複数回実行されることがあるため

  source_code_hash = data.archive_file.function_zip.output_base64sha256
  layers           = [aws_lambda_layer_version.notify_lambda_layer.arn]

  filename = data.archive_file.function_zip.output_path

  environment {
    variables = {
      WEBHOOK_URL = var.WEBHOOK_URL
    }
  }
}

resource "aws_cloudwatch_event_rule" "billing_rule" {
  name                = "daily-billing"
  description         = "Daily AWS Billing Check"
  schedule_expression = "cron(0 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.billing_rule.name
  target_id = "billing-lambda"
  arn       = aws_lambda_function.notify.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.billing_rule.arn
}
