locals {
    tags = merge(var.tags, {
       x-cross-account="true"
    })

  create_kms_key = var.kms_id == null

  bucket_policies = merge(
    {
      for index, policy in data.aws_iam_policy_document.cross_account_policy : "cross_account_${index}" => {
        create = true
        json = policy.json
      }
    },
    {
      custom = {
        create = var.bucket_policy != null
        json = var.bucket_policy
      }
    }
  )

  bucket_allowed_actions = {
    Read = local.read_bucket_allowed_actions
    Write = local.write_bucket_allowed_actions
    Full = local.full_bucket_allowed_actions
  }

  read_bucket_allowed_actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts"
  ]
  write_bucket_allowed_actions = [
    "s3:PutAccelerateConfiguration",
    "s3:PutBucketAcl",
    "s3:PutBucketPolicy",
    "s3:AbortMultipartUpload",
    "s3:DeleteObject",
    "s3:DeleteObjectVersion",
    "s3:PutObject",
    "s3:PutObjectAcl"
  ]
  full_bucket_allowed_actions = concat(local.read_bucket_allowed_actions,local.write_bucket_allowed_actions)
}