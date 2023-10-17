resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  tags = local.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.owner_preferred,
  aws_s3_bucket_public_access_block.deny_public_access]
  bucket = aws_s3_bucket.bucket.bucket
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "deny_public_access" {
  bucket = aws_s3_bucket.bucket.bucket
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_ownership_controls" "owner_preferred" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.kms_id == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_id
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.bucket
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count = local.has_bucket_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.bucket.bucket

  dynamic "rule" {
    for_each = local.transition ?  [var.lifecycle_transition ] : [ ]
    content {
      id = rule.value.id
      status = rule.value.status

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.nonconcurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  dynamic "rule" {
    for_each = local.multipart_upload ? [var.lifecycle_multipart] : []
    content {
      id = rule.value.id
      status = rule.value.status
      abort_incomplete_multipart_upload {
        days_after_initiation = rule.value.days_after_initiation
      }
    }
  }

  dynamic "rule" {
    for_each = local.expiration ? [local.data_retention] : []
    content {
      id = rule.value.id
      status = rule.value.status
      expiration {
        days = rule.value.expiration_days
      }
    }
  }

  dynamic "rule" {
    for_each = local.versioning ? [local.data_versioning] : []
    content {
      id = rule.value.id
      status = rule.value.status
     noncurrent_version_expiration {
       newer_noncurrent_versions = rule.value.newer_noncurrent_versions
       noncurrent_days = rule.value.noncurrent_days
     }
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "bucket_tiering" {
  count = var.intelligent_tiering.status != null ? 1:0
  bucket = aws_s3_bucket.bucket.bucket
  name   = var.intelligent_tiering.name
  status = var.intelligent_tiering.status

  dynamic "tiering" {
    for_each = var.intelligent_tiering.tierings
    content {
      days = tiering.value.days
      access_tier = tiering.value.access_tier
    }
  }
}