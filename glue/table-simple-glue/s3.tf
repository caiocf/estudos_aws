
# Criação do Bucket S3
resource "aws_s3_bucket" "sor_bucket" {
  # bucket = "nome-do-seu-bucket-de-dados"
  bucket =  local.sor_s3bucket
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
  key    = "${var.sor_table_name}/anomesdia=20231027/dados_dispositivo_amostra.parquet"
  source = "dados_dispositivo_amostra_20.parquet"
  etag   = filemd5("dados_dispositivo_amostra_20.parquet")

  depends_on = [
    aws_s3_bucket.sor_bucket,
    aws_s3_bucket_public_access_block.sor_bucket_access
  ]
}

resource "aws_s3_object" "upload_amostra_2" {
  bucket = local.sor_s3bucket
  key    = "${var.sor_table_name_2}/ano=2023/mes=11/dia=20/dados_dispositivo_amostra.parquet"
  source = "dados_dispositivo_amostra_20.parquet"
  etag   = filemd5("dados_dispositivo_amostra_20.parquet")

  depends_on = [
    aws_s3_bucket.sor_bucket,
    aws_s3_bucket_public_access_block.sor_bucket_access
  ]
}