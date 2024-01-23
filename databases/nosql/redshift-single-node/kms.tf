
resource "aws_kms_key" "redshift_key" {
  description             = "KMS key for Redshift cluster"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  #checkov:skip=CKV2_AWS_64: Not including a KMS Key policy
}

resource "aws_kms_alias" "redshift_key_alias" {
  name          = "alias/redshift-key-vendas"
  target_key_id = aws_kms_key.redshift_key.key_id
}

resource "aws_kms_key_policy" "redshift_key" {
  key_id = aws_kms_key.redshift_key.id
  policy = jsonencode({
    Id = "key-default-1"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = local.principal_root_arn
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Effect : "Allow",
        Principal : {
          Service : local.principal_logs_arn
        },
        Action : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource : "*",
        Condition : {
          ArnEquals : {
            "kms:EncryptionContext:aws:logs:arn" : [local.slow_log_arn, local.engine_log_arn]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}