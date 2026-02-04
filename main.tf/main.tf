# 1. Provedor
provider "aws" {
  region = "us-east-1"
}

# 2. Bucket S3
resource "aws_s3_bucket" "recibos_bucket" {
  bucket = "cloudorder-recibos-github-deploy" # Nome único
}

# 3. Fila SQS
resource "aws_sqs_queue" "orders_queue" {
  name = "OrdersQueue-Terraform"
}

# 4. Exemplo de Lambda (Simplificado)
resource "aws_lambda_function" "sqs_to_sf" {
  filename      = "lambda.zip"
  function_name = "SQS-to-StepFunction-Terraform"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
}