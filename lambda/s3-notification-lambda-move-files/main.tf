provider "aws" {
  region = var.aws_region
}
locals {
  source_bucket_name = "${var.source_bucket_name}-${data.aws_caller_identity.current.account_id}"
  destination_bucket_name = "${var.destination_bucket_name}-${data.aws_caller_identity.current.account_id}"
}

# -------------------------
# S3 buckets
# -------------------------
resource "aws_s3_bucket" "source" {
  bucket = local.source_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "destination" {
  bucket = local.destination_bucket_name
  force_destroy = true
}

# Bloquear acesso público (boa prática)
resource "aws_s3_bucket_public_access_block" "source" {
  bucket                  = aws_s3_bucket.source.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "destination" {
  bucket                  = aws_s3_bucket.destination.id
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
# Lambda function
# -------------------------
resource "aws_lambda_function" "s3_move" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DESTINATION_BUCKET = local.destination_bucket_name
    }
  }
}

# Permissão para o S3 invocar a Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_move.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

# Notificação no bucket de origem: ao criar objeto .csv => dispara Lambda
resource "aws_s3_bucket_notification" "source_notify" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_move.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}


# Upload s3 para S3 Notification
resource "aws_s3_object" "upload_csv" {
  bucket = aws_s3_bucket.source.bucket
  key    = "customer.csv"
  source = "${path.module}/customer.csv"
  etag   = filemd5("${path.module}/customer.csv")

  depends_on = [aws_lambda_function.s3_move,aws_s3_bucket.destination,aws_s3_bucket.source]
}
