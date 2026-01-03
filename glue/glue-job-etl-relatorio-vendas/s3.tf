resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# “Pastas” (na prática, objetos vazios) só pra padronizar
resource "aws_s3_object" "bronze_prefix" {
  bucket  = aws_s3_bucket.data.id
  key     = "${trim(var.bronze_prefix, "/")}/"
  content = ""
}

resource "aws_s3_object" "silver_prefix" {
  bucket  = aws_s3_bucket.data.id
  key     = "${trim(var.silver_prefix, "/")}/"
  content = ""
}

resource "aws_s3_object" "tmp_prefix" {
  bucket  = aws_s3_bucket.data.id
  key     = "tmp/"
  content = ""
}

# Upload do script do Glue para o S3
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.data.id
  key    = "${trim(var.scripts_prefix, "/")}/glue_job.py"
  source = "${path.module}/scripts/glue_job.py"
  etag   = filemd5("${path.module}/scripts/glue_job.py")
}


resource "aws_s3_object" "customers_amostra" {
  bucket = aws_s3_bucket.data.id
  key    = "${var.bronze_prefix}/customers/ano=2023/mes=10/dia=28/customers_20251231T235959Z_3f2a1c7e.csv"
  source = "${path.module}/data/customers_20251231T235959Z_3f2a1c7e.csv"
  etag   = filemd5("${path.module}/data/customers_20251231T235959Z_3f2a1c7e.csv")
}

resource "aws_s3_object" "orders_amostra" {
  bucket = aws_s3_bucket.data.id
  key    = "${var.bronze_prefix}/orders/ano=2023/mes=10/dia=28/orders_20251231T235959Z_2c2a1cab.csv"
  source = "${path.module}/data/orders_20251231T235959Z_2c2a1cab.csv"
  etag   = filemd5("${path.module}/data/orders_20251231T235959Z_2c2a1cab.csv")
}