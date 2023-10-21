data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  source_policy_documents = [for policy in local.bucket_policies : policy.json if policy.create]
}

data "aws_iam_policy_document" "storage_gateway_policy" {
  statement {
    sid = "AllowAccessStorageGatewayBucket"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
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
      #"s3:GetAccelerateConfiguration",
      #"s3:GetBucketAcl",
      #"s3:GetBucketLocation",
      #"s3:GetBucketVersioning",
      #"s3:ListBucket",
      #"s3:ListBucketVersions",
      #"s3:ListBucketMultipartUploads",
      #"s3:PutAccelerationConfiguration",
      #"s3:PutBucketAcl",
      #"s3:PutBucketPolicy",
      #"s3:AbortMultipartUpload",
      #"s3:DeleteObject",
      #"s3:DeleteObjectVersion",

      #"s3:GetObjectAcl",
      #"s3:GetObjectVersion",
      #"s3:ListMultipartUploadParts",

      #"s3:PutObjectAcl"
    ]
    resources = ["${module.bucket_s3_storage_gateway.s3_bucket_arn}/*",
      module.bucket_s3_storage_gateway.s3_bucket_arn
    ]
  }

}