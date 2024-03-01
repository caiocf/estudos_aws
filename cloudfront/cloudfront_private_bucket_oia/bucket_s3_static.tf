
resource "aws_s3_bucket" "web_site" {
  bucket = "meu-website-${random_string.bucket_suffix.result}"
  provider = aws.primary
  force_destroy = true

}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.web_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = ["${aws_s3_bucket.web_site.arn}/*",aws_s3_bucket.web_site.arn]
        //Principal = {"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"}
        Principal = {"AWS": aws_cloudfront_origin_access_identity.oai.iam_arn}
      },
    ]
  })
}

/*resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.web_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
*/

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.web_site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "index_root" {
  bucket = aws_s3_bucket.web_site.id
  key    = "documents/index.html"
  content_type = "text/html"
  source = "arquivos_bucket/docs.html"
}

resource "aws_s3_object" "index_docs" {
  bucket = aws_s3_bucket.web_site.id
  key    = "index.html"
  content_type = "text/html"
  source = "arquivos_bucket/index.html"
}
resource "aws_s3_object" "index_error" {
  bucket = aws_s3_bucket.web_site.id
  key    = "error.html"
  content_type = "text/html"
  source = "arquivos_bucket/error.html"
}

resource "aws_s3_bucket_public_access_block" "example_access_block" {
  bucket = aws_s3_bucket.web_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls_example" {
  bucket = aws_s3_bucket.web_site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  bucket = aws_s3_bucket.web_site.id

  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers = []
    max_age_seconds = 0
  }
}