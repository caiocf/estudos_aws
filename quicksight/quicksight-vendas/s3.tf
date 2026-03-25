locals {
  bucket_name           = coalesce(var.s3_bucket_name, "vendas-data-${data.aws_caller_identity.current.account_id}")
  athena_results_bucket = coalesce(var.athena_results_bucket_name, "athena-results-vendas-${data.aws_caller_identity.current.account_id}")
}

data "aws_iam_policy_document" "athena_results" {
  statement {
    sid    = "AthenaQueryResultsAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["athena.amazonaws.com"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.athena_results.arn,
      "${aws_s3_bucket.athena_results.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "QuickSightQueryResultsAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["quicksight.amazonaws.com"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.athena_results.arn,
      "${aws_s3_bucket.athena_results.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket" "vendas" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy_buckets
  tags = {
    Environment = "Analytics"
    DataLayer   = "Raw"
  }
}

resource "aws_s3_bucket_public_access_block" "vendas" {
  bucket = aws_s3_bucket.vendas.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vendas" {
  bucket = aws_s3_bucket.vendas.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket para resultados de queries do Athena
resource "aws_s3_bucket" "athena_results" {
  bucket        = local.athena_results_bucket
  force_destroy = var.force_destroy_buckets

  tags = {
    Environment = "Analytics"
    Purpose     = "AthenaQueryResults"
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  policy = data.aws_iam_policy_document.athena_results.json

  depends_on = [aws_s3_bucket_public_access_block.athena_results]
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "expire-query-results"
    status = "Enabled"

    expiration {
      days = var.athena_results_retention_days
    }
  }
}

resource "aws_s3_object" "orders_csv" {
  bucket = aws_s3_bucket.vendas.id
  key    = "${var.glue_table_name}/orders_full.csv"
  source = "data/orders_full.csv"
  etag   = filemd5("data/orders_full.csv")

  depends_on = [aws_s3_bucket.vendas]
}
