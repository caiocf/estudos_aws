#iam#
data "aws_iam_policy_document" "storagegateway" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["storagegateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3-bucket-access" {
  statement {
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3-bucket-access" {
  policy = data.aws_iam_policy_document.s3-bucket-access.json
}

resource "aws_iam_role" "gateway" {
  name               = "${aws_storagegateway_gateway.storage-gateway.gateway_name}-role"
  assume_role_policy = data.aws_iam_policy_document.storagegateway.json
}

resource "aws_iam_role_policy_attachment" "gateway-attach" {
  role       = aws_iam_role.gateway.name
  policy_arn = aws_iam_policy.s3-bucket-access.arn
}