
data "aws_ec2_instance_types" "available" {}

data "aws_ami" "amazonLinux_regiao1"{
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]

  provider = aws.primary
}


data "aws_iam_policy_document" "policyt_bucket_s3_example" {
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
    resources = ["${aws_s3_bucket.example_bucket.arn}/*",
      aws_s3_bucket.example_bucket.arn
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

