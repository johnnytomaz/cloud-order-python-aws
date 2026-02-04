terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Bucket S3 (Mude o nome se já existir!)
resource "aws_s3_bucket" "bucket_projeto" {
  bucket = "cloudorder-recibos-iac-2026" 
}

# 2. Fila SQS
resource "aws_sqs_queue" "fila_pedidos" {
  name = "OrdersQueue-IaC"
}

# 3. Role (Crachá) da Step Function
resource "aws_iam_role" "role_sfn" {
  name = "StepFunctionRole-IaC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

# 4. Permissão para a Step Function escrever no S3
resource "aws_iam_role_policy" "sfn_s3_policy" {
  name = "SfnWriteToS3"
  role = aws_iam_role.role_sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = ["${aws_s3_bucket.bucket_projeto.arn}/*"]
    }]
  })
}

# 5. A Step Function
resource "aws_sfn_state_machine" "minha_state_machine" {
  name     = "FluxoPedidos-IaC"
  role_arn = aws_iam_role.role_sfn.arn

  definition = jsonencode({
    StartAt = "GravarNoS3",
    States = {
      GravarNoS3 = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:s3:putObject",
        Parameters = {
          "Bucket": aws_s3_bucket.bucket_projeto.id,
          "Key": "pedido-recebido.json",
          "Body.$": "$"
        },
        End = true
      }
    }
  })
}