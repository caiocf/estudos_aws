provider "aws" {
  region = var.aws_region
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example_bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "meuArquivo.txt"
  source = "meuArquivo.txt"
}

resource "aws_s3_bucket_public_access_block" "example_access_block" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls_example" {
  bucket = aws_s3_bucket.example_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls_example]
  bucket = aws_s3_bucket.example_bucket.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "READ"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "READ_ACP"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}
