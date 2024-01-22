#Create a policy to read from the specific parameter store
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "app-4-ssm-parameter-read-policy"
  path        = "/"
  description = "Policy to read the ElastiCache endpoint and port number stored in the SSM Parameter Store."
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [aws_ssm_parameter.elasticache_ep.arn, aws_ssm_parameter.elasticache_port.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.encryption_rest.arn]
      }
    ]
  })
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "secret_manager_policy" {
  name        = "app-4-secret-read-policy"
  path        = "/"
  description = "Policy to read the ElastiCache AUTH Token stored in AWS Secrets Manager secret."
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [aws_secretsmanager_secret_version.auth.arn]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.encryption_secret.arn]
      }
    ]
  })
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_role_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ssm_policy_attachment_ec2_role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  roles = [aws_iam_role.ec2_role.name]
}


resource "aws_iam_policy_attachment" "secret_policy_attachment" {
  name       = "secret_policy_attachment_ec2_role"
  policy_arn = aws_iam_policy.secret_manager_policy.arn
  roles = [aws_iam_role.ec2_role.name]
}

