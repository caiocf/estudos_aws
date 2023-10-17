locals {
  bucket_name = var.name_suffix == "" ? var.name : "${var.name}-${var.name_suffix}"

  tags = merge(var.tags, {
    s3_data_classification  = var.s3_data_classification
    s3_data_retention = var.s3_data_retention
    s3_bucket_type = var.s3_bucket_type
  })

  bucket_policies = {
    default = {
      create = true
      json = data.aws_iam_policy_document.default_policy.json
    }
    custom = {
      create = var.bucket_policy != null
      json = var.bucket_policy
    }
  }

  expiration  = var.s3_data_retention != 0
  transition = var.lifecycle_transition.status != null
  multipart_upload = var.lifecycle_multipart.status != null
  versioning = var.versioning != null
  has_bucket_lifecycle = local.expiration || local.transition || local.multipart_upload || local.versioning

  data_retention = {
    id = "Data retention"
    status = local.expiration? "Enabled": "Disabled"
    expiration_days = var.s3_data_retention
  }

  data_versioning = {
    id = "Non current data retention"
    status = local.versioning ? "Enabled" : "Disabled"
    newer_noncurrent_versions = try(var.lifecycle_versioning.keep_last_versions, null)
    noncurrent_days = try(var.lifecycle_versioning.keep_for_days, null)
  }
}