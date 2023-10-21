data "aws_caller_identity" "current" {}

# Verifique se o usuário "Vault-IAM" já existe
data "aws_iam_user" "existing_user" {
  user_name = var.user_name
}

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
    resources = ["${var.arn_bucket}/*",
        var.arn_bucket
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

