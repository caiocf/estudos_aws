module "bucket_s3_storage_gateway" {
  source = "../../"
  name = var.name
  name_suffix = var.name_suffix

  s3_bucket_type = "private"
  s3_data_classification = var.s3_data_classification
  s3_data_retention = var.s3_data_retention

  tags = var.tags

  kms_id = var.kms_id
  bucket_policy = data.aws_iam_policy_document.policy.json

  force_destroy = var.force_destroy
  versioning = var.versioning
  lifecycle_versioning = var.lifecycle_versioning

  lifecycle_transition = var.lifecycle_transition
  lifecycle_multipart = var.lifecycle_multipart
  intelligent_tiering = var.intelligent_tiering
}