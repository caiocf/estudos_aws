/*

resource "aws_iam_role" "example_role" {
  name = "ExampleRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Vault-IAM"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Anexar uma política adicional à role, se necessário
resource "aws_iam_policy" "example_policy" {
  name        = "ExamplePolicy"
  description = "Exemplo de política"

  policy = data.aws_iam_policy_document.storage_gateway_policy.json
}

# Anexar a política à role
resource "aws_iam_policy_attachment" "example_policy_attachment" {
  name = "example_policy_attachment"
  policy_arn = aws_iam_policy.example_policy.arn
  roles      = [aws_iam_role.example_role.name]
}
*/
