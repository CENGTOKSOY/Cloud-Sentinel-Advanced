terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://127.0.0.1:4566"
    sqs      = "http://127.0.0.1:4566"
    lambda   = "http://127.0.0.1:4566"
    iam      = "http://127.0.0.1:4566"
    dynamodb = "http://127.0.0.1:4566"
  }
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "sentinel-advanced-input"
}

resource "aws_sqs_queue" "analytics_queue" {
  name = "sentinel-analytics-queue"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Principal = { Service = "lambda.amazonaws.com" }, Effect = "Allow" }]
  })
}

resource "aws_lambda_function" "image_processor" {
  filename      = "../../../services/image-processor/function.zip"
  function_name = "sentinel-image-processor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"

  environment {
    variables = {
      SQS_QUEUE_URL = "http://127.0.0.1:4566/000000000000/sentinel-analytics-queue"
      LOCALSTACK_ENDPOINT = "http://127.0.0.1:4566"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_dynamodb_table" "analytics_results" {
  name           = "sentinel-analytics-results"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
