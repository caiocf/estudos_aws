provider "aws" {
  region = var.aws_region
}

locals {
  s3_bucket_name = "${var.s3_bucket_name}-${data.aws_caller_identity.current.account_id}"

}
# -------------------------
# Kinesis Data Stream (PROVISIONED)
# -------------------------
resource "aws_kinesis_stream" "this" {
  name             = var.stream_name
  retention_period = var.retention_hours
  shard_count      = var.shard_count

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = var.tags
}

# -------------------------
# S3 bucket (destination)
# -------------------------
resource "aws_s3_bucket" "this" {
  bucket = local.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------
# Lambda packaging
# -------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

# -------------------------
# IAM role for Lambda
# -------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions to read from Kinesis via event source mapping
resource "aws_iam_role_policy_attachment" "lambda_kinesis_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

# Write objects to the destination S3 bucket
resource "aws_iam_policy" "lambda_s3_put" {
  name = "${var.lambda_name}-s3-put"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ],
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_put_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_put.arn
}

# -------------------------
# Lambda function (consumer)
# -------------------------
resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = var.s3_bucket_name
    }
  }

  tags = var.tags
}

# -------------------------
# Kinesis -> Lambda event source mapping
# -------------------------
resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = aws_kinesis_stream.this.arn
  function_name     = aws_lambda_function.this.arn
  starting_position = "LATEST"

  # Adjust as needed
  batch_size                         = 100
  maximum_batching_window_in_seconds = 1
  enabled                            = true
}
