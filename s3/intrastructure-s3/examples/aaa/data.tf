data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "storage_gateway_policy" {
  statement {
    sid = "AllowAccessStorageGatewayBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
    ]
    resources = ["${module.bucket_s3_storage_gateway.s3_bucket_arn}/*",
      module.bucket_s3_storage_gateway.s3_bucket_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:GeneratedDataKey",
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:*:*:key/*"]
  }
}


