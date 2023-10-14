provider "aws" {
  region = var.aws_region
}

resource "aws_iam_policy" "logstream" {
  name        = var.logstream_policy_name
  description = "Permite que os contêineres do Amazon ECS enviem logs para o CloudWatch Logs, acessem o bucket S3 para armazenamento de logs e recuperem segredos do Secrets Manager para configuração segura de aplicativos e logs."

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
        }
    ]
}
EOF
}

resource "aws_iam_policy" "artifact" {
  name        = var.artifact_policy_name
  description = "Permite que os contêineres do Amazon ECS recuperem imagens do Amazon ECR (Elastic Container Registry), acessem o bucket S3 para recursos gerais, recuperem segredos do Secrets Manager para configuração segura de aplicativos e executem tarefas de contêiner com permissões adequadas."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetImageManifest",
                "s3:GetObject",
                "s3:PutObject",
                "secretsmanager:GetSecretValue",
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecsExecutionRole" {
  name = "ecs_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecsTaskRole" {
  name = "ecs_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Política attachment
resource "aws_iam_policy_attachment" "artifact_policy_attachment" {
  name       = "iam_policy_attachment_artifact"
  policy_arn = aws_iam_policy.artifact.arn
  roles      = [aws_iam_role.ecsExecutionRole.name, aws_iam_role.ecsTaskRole.name]
}

resource "aws_iam_policy_attachment" "logstream_policy_attachment" {
  name       = "iam_policy_attachment_logStream"
  policy_arn = aws_iam_policy.logstream.arn
  roles      = [aws_iam_role.ecsExecutionRole.name, aws_iam_role.ecsTaskRole.name]
}
