# Defina a versão do provider AWS
provider "aws" {
  region = "us-east-1"
}

# Crie uma política personalizada que concede permissões necessárias
resource "aws_iam_policy" "ec2CloudWatchS3Policy" {
  name        = "EC2CloudWatchS3SecretsPolicy"
  description = "Permite que as instâncias EC2 enviem logs para o CloudWatch Logs, acessem o bucket S3 e recuperem segredos do Secrets Manager, garantindo conexões seguras via HTTPS."
  # Use a política JSON que definimos anteriormente e adicione permissões do Secrets Manager
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${var.nome_bucket}/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue",
              "ssm:GetParameters",
              "kms:Decrypt",
              "ec2:Describe*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}



# Crie uma função IAM que pode ser usada pelas instâncias EC2
resource "aws_iam_role" "ec2CloudWatchS3Role" {
  name = "EC2CloudWatchS3Role"

  # Anexe uma política à função
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Anexe a política criada anteriormente à função IAM
resource "aws_iam_policy_attachment" "EC2CloudWatchS3Policy_policy_attachment" {
  policy_arn = aws_iam_policy.ec2CloudWatchS3Policy.arn
  roles      = [aws_iam_role.ec2CloudWatchS3Role.name]
  name       = "iam_policy_attachment_ec2CloudWatchS3Role"
}

