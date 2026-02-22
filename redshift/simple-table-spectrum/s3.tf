
# Criação do Bucket S3
resource "aws_s3_bucket" "sor_bucket" {
  bucket = "nome-do-seu-bucket-de-dados-${random_string.bucket_suffix.result}"

  force_destroy = true
  tags = {
    Environment = "Governança"
    DataLayer   = "SOR"
  }
}

# Bloqueio de Acesso Público (Boa prática de segurança)
resource "aws_s3_bucket_public_access_block" "sor_bucket_access" {
  bucket = aws_s3_bucket.sor_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Criptografia do Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "sor_bucket_encryption" {
  bucket = aws_s3_bucket.sor_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_object" "upload_vendas" {
  bucket = aws_s3_bucket.sor_bucket.bucket
  key    = "vendas/vendas_1.csv"
  source = "vendas_1.csv"
  etag   = filemd5("vendas_1.csv")

  depends_on = [
    aws_s3_bucket.sor_bucket,
    aws_s3_bucket_public_access_block.sor_bucket_access
  ]
}

resource "aws_s3_object" "upload_clientes" {
  bucket = aws_s3_bucket.sor_bucket.bucket
  key    = "clientes/customers_1.csv"
  source = "customers_1.csv"
  etag   = filemd5("customers_1.csv")

  depends_on = [
    aws_s3_bucket.sor_bucket,
    aws_s3_bucket_public_access_block.sor_bucket_access
  ]
}

##################################
resource "aws_s3_bucket" "redshift_logs" {
  bucket = "redshift-logs-${random_string.bucket_suffix.result}"
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "log_bucket_public_access_block" {
  bucket = aws_s3_bucket.redshift_logs.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "redshift_logs_policy" {
  bucket = aws_s3_bucket.redshift_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketAcl"
        ],
        Resource = [
          "${aws_s3_bucket.redshift_logs.arn}/*",
          aws_s3_bucket.redshift_logs.arn
        ]
      },
      {
        Effect    = "Allow",
        Principal = {"Service": "delivery.logs.amazonaws.com"},
        Action    = ["s3:PutObject"],
        Resource  = "${aws_s3_bucket.redshift_logs.arn}/*",
        Condition = {
          StringEquals = {"s3:x-amz-acl": "bucket-owner-full-control"}
        }
      }
    ]
  })
}



resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}
