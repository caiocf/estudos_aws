terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name       = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-${data.aws_region.current.name}-${random_id.suffix.hex}"
  lambda_zip_path   = "${path.module}/../artifacts/watermark_lambda.zip"
  pillow_layer_path = "${path.module}/../artifacts/pillow_layer.zip"

  common_tags = merge(
    {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Repository  = "study-demo"
      Environment = var.environment
    },
    var.tags
  )
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/handler.py"
  output_path = local.lambda_zip_path
}

resource "aws_s3_bucket" "images" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda_exec" {
  name = "${var.project_name}-lambda-inline-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Sid    = "AllowReadOriginalImages"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.images.arn}/${trim(var.source_prefix, "/")}/*"
      },
      {
        Sid    = "AllowWriteWatermarkedImages"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:PutObjectTagging"]
        Resource = "${aws_s3_bucket.images.arn}/${trim(var.destination_prefix, "/")}/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-watermark"
  retention_in_days = var.log_retention_in_days
  tags              = local.common_tags
}

resource "aws_lambda_layer_version" "pillow" {
  filename            = local.pillow_layer_path
  layer_name          = "${var.project_name}-pillow"
  compatible_runtimes = [var.lambda_runtime]
  source_code_hash    = filebase64sha256(local.pillow_layer_path)

  lifecycle {
    precondition {
      condition     = fileexists(local.pillow_layer_path)
      error_message = "The file artifacts/pillow_layer.zip was not found. Run ./scripts/build_layer.sh before terraform apply."
    }
  }
}

resource "aws_lambda_function" "watermark" {
  function_name = "${var.project_name}-watermark"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = var.lambda_runtime

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = var.lambda_timeout_seconds
  memory_size = var.lambda_memory_mb
  layers      = [aws_lambda_layer_version.pillow.arn]

  environment {
    variables = {
      BUCKET_NAME        = aws_s3_bucket.images.bucket
      SOURCE_PREFIX      = trim(var.source_prefix, "/")
      DESTINATION_PREFIX = trim(var.destination_prefix, "/")
      WATERMARK_TEXT     = var.watermark_text
      WATERMARK_OPACITY  = tostring(var.watermark_opacity)
      OUTPUT_FORMAT      = var.output_format
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watermark.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images.arn
}

resource "aws_s3_bucket_notification" "images" {
  bucket = aws_s3_bucket.images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.watermark.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${trim(var.source_prefix, "/")}/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
