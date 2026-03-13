# IAM User para consumo/consulta no Lake Formation
resource "aws_iam_user" "aws_user" {
  name = var.iam_user_name

  tags = {
    Name        = "Lake Formation User"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Role dedicada para registrar a data location no Lake Formation.
# Evita a dependência da service-linked role, que pode falhar ao destruir
# a última S3 location registrada.
resource "aws_iam_role" "lakeformation_data_access" {
  name = "${var.database_name}-lf-data-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Lake Formation Data Access Role"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "lakeformation_data_access" {
  name = "${var.database_name}-lf-data-access-policy"
  role = aws_iam_role.lakeformation_data_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BucketMetadataAccess"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketAcl",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = aws_s3_bucket.glue_lake.arn
      },
      {
        Sid    = "ObjectReadWriteAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "${aws_s3_bucket.glue_lake.arn}/*"
      }
    ]
  })
}
