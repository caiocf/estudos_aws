

resource "aws_iam_role" "s3_storage_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_name}"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Anexar uma política adicional à role, se necessário
resource "aws_iam_policy" "policy_s3_storage" {
  name        = var.policy_name
  description = "Politica usuario assumer role do s3 para storage gateway"

  policy = data.aws_iam_policy_document.storage_gateway_policy.json
}

# Anexar a política à role
resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name = var.policy_attachment_name
  policy_arn = aws_iam_policy.policy_s3_storage.arn
  roles      = [aws_iam_role.s3_storage_role.name]
}
