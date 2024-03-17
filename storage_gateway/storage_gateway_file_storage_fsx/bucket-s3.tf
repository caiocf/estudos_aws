resource "aws_s3_bucket" "bucket" {
  // size max 63
  bucket = "meus-dados-storage-gateway-${data.aws_caller_identity.current.account_id}"

  provider = aws.primary

  force_destroy = true

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  provider = aws.primary

  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "example_access_block" {
  provider = aws.primary

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
