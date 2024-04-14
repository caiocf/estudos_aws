##### Creating a Random String #####
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
}


resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${random_string.random.result}"

  provider = aws.primary
  force_destroy = true
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  provider = aws.primary

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket.id
  provider = aws.primary
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.bucket.id
  content_type = "text/html"

  etag = filemd5("index.html")
  key    = "index.html"
  #source = "index.html"
  content =  data.template_file.s3_website_blog.rendered

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "example_access_block" {
  bucket = aws_s3_bucket.bucket.id
  provider = aws.primary
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls_example" {
  bucket = aws_s3_bucket.bucket.id
  provider = aws.primary
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.bucket.id

  depends_on = [aws_s3_bucket.bucket]

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "MYBUCKETPOLICY",
    "Statement": [
      {
        "Sid": "Stmt1234567890123",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
      }
    ]
  }
POLICY
}