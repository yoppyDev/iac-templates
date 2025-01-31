provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Name = "kintone-to-alexa"
    }
  }
}

# ECRリポジトリの作成（ベースイメージ用）
resource "aws_ecr_repository" "base_image_repo" {
  name         = "lambda-base-image"
  force_delete = true
}

# ECRリポジトリの作成（Lambda関数用）
resource "aws_ecr_repository" "lambda_function_repo" {
  name         = "lambda-function-image"
  force_delete = true
}

locals {
  ecr_registry_url = split("/", aws_ecr_repository.base_image_repo.repository_url)[0]
}

# ベースイメージのビルドとプッシュ
resource "null_resource" "build_and_push_base_image" {
  triggers = {
    base_dockerfile_hash = filesha256("${path.module}/base/Dockerfile")
  }

  provisioner "local-exec" {
    command     = <<-EOF
      # ECRへのログイン
      aws ecr get-login-password --profile default |
        docker login --username AWS --password-stdin ${local.ecr_registry_url}

      # ベースイメージのビルド
      docker build --platform linux/amd64 -t ${aws_ecr_repository.base_image_repo.repository_url}:latest ./base

      # ECRにプッシュ
      docker push ${aws_ecr_repository.base_image_repo.repository_url}:latest
    EOF
    interpreter = ["/bin/sh", "-c"]
  }
}

# Lambda関数イメージのビルドとプッシュ（スクリプトのみ）
resource "null_resource" "build_and_push_lambda_image" {
  triggers = {
    lambda_dockerfile_hash = filesha256("${path.module}/build/Dockerfile")
    lambda_script_hash     = filesha256("${path.module}/build/lambda_function.py")
  }
  depends_on = [null_resource.build_and_push_base_image]

  provisioner "local-exec" {
    command = <<-EOF
      # ECRへのログイン
      aws ecr get-login-password --profile default |
        docker login --username AWS --password-stdin ${local.ecr_registry_url}

      # Lambda関数イメージのビルド（ベースイメージを利用）
      docker build --platform linux/amd64 \
        -t ${aws_ecr_repository.lambda_function_repo.repository_url}:latest \
        --build-arg BASE_IMAGE=${aws_ecr_repository.base_image_repo.repository_url}:latest \
        ./build

      # ECRにプッシュ
      docker push ${aws_ecr_repository.lambda_function_repo.repository_url}:latest
    EOF
  }
}

# IAMロールの作成
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action" : "sts:AssumeRole",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      }
    }]
  })
}

# IAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ecr_read" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Lambda関数の作成
resource "aws_lambda_function" "lambda_function" {
  function_name = "kintone-to-alexa"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda_function_repo.repository_url}:latest"
}

# Lambda関数にAlexaからのアクセスを許可
resource "aws_lambda_permission" "allow_alexa" {
  statement_id       = "AllowExecutionFromAlexa"
  action             = "lambda:InvokeFunction"
  function_name      = aws_lambda_function.lambda_function.function_name
  principal          = "alexa-appkit.amazon.com"
  event_source_token = var.event_source_token
}