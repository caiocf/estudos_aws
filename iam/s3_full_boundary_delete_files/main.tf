provider "aws" {
  region = var.aws_region
}

# 1. Permission Boundary - Define o limite de permissão que impede a exclusão de objetos S3
resource "aws_iam_policy" "s3_boundary_no_delete" {
  name        = "S3BoundaryNoDelete"
  description = "Boundary policy that allows all S3 actions except deleting objects"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
      },
      {
        "Effect": "Deny",
        "Action": [
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::*/*"
      }
    ]
  })
}

# 2. IAM Role - Cria a role com a relação de confiança
resource "aws_iam_role" "s3_access_role" {
  name               = "S3AccessRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.trusted_account_id}:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  # Associa o permission boundary à role
  permissions_boundary = aws_iam_policy.s3_boundary_no_delete.arn
}


# 3. Data Source para obter o ID da conta atual
data "aws_caller_identity" "current" {}


# 4. Anexa a política AmazonS3FullAccess à role criada
resource "aws_iam_role_policy_attachment" "s3_full_access_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
