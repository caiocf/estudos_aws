data "aws_iam_policy_document" "policy"{
  source_policy_documents = [ for policy in local.bucket_policies : policy.json if policy.create]
}

data "aws_iam_policy_document" "default_policy"{
  statement {
    sid = "AllowSSLRequestOnly"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    effect = "Deny"
    actions = ["s3:*"]
    resources = [
    "${aws_s3_bucket.bucket.arn}/*",
      aws_s3_bucket.bucket.arn
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}