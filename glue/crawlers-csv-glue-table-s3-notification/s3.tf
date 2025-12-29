
# Criação do Bucket S3
resource "aws_s3_bucket" "sor_bucket" {
  # bucket = "nome-do-seu-bucket-de-dados"
  bucket =  local.sor_s3bucket
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

resource "aws_s3_object" "upload_amostra" {
  bucket = local.sor_s3bucket
  key    = "${var.sor_table_name}/ano=2023/mes=10/dia=28/customers_1.csv"
  source = "customers_1.csv"
  etag   = filemd5("customers_1.csv")

  depends_on = [
    aws_s3_bucket.sor_bucket,
    aws_s3_bucket_public_access_block.sor_bucket_access,
    aws_s3_bucket_notification.to_sqs
  ]
}


resource "aws_s3_bucket_notification" "to_sqs" {
  bucket = aws_s3_bucket.sor_bucket.id

  queue {
    queue_arn = aws_sqs_queue.s3_sqs_events.arn
    events    = ["s3:ObjectCreated:*"]

    # opcional: filtrar por "pasta" e extensão
    #filter_prefix = "uploads/"
    filter_suffix = ".csv"
  }

  # importante: evita "Unable to validate the following destination configurations"
  depends_on = [aws_sqs_queue_policy.s3_events_queue_policy]
}