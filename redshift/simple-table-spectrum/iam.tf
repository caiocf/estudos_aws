# iam.tf
data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "redshift_s3_spectrum_role" {
  name               = "redshift-s3-spectrum-role"
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
}

# Política mínima para:
# - COPY/UNLOAD com S3 (leitura e escrita)
# - Spectrum com Glue Data Catalog
data "aws_iam_policy_document" "redshift_access" {
  statement {
    sid     = "S3ReadWriteForCopyUnload"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "${aws_s3_bucket.sor_bucket.arn}",
      "${aws_s3_bucket.sor_bucket.arn}/*"
    ]
  }

  statement {
    sid     = "GlueCatalogForSpectrum"
    effect  = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:CreateDatabase",
      "glue:UpdateDatabase",
      "glue:DeleteDatabase"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "redshift_access" {
  name   = "redshift-s3-glue-access"
  policy = data.aws_iam_policy_document.redshift_access.json
}

resource "aws_iam_role_policy_attachment" "attach_redshift_access" {
  role       = aws_iam_role.redshift_s3_spectrum_role.name
  policy_arn = aws_iam_policy.redshift_access.arn
}