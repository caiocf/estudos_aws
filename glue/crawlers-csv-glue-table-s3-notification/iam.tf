# 1. Role de IAM
resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Política de acesso ao S3 e CloudWatch Logs
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


# Política customizada para o seu bucket específico
resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue-s3-access-policy"
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket" # Adicionado ListBucket, essencial para o Crawler
        ]
        # AJUSTE AQUI: Usando o ARN do bucket + /*
        Resource = [
          "${aws_s3_bucket.sor_bucket.arn}",
          "${aws_s3_bucket.sor_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "glue_sqs_access" {
  name = "glue-sqs-access-policy"
  role = aws_iam_role.glue_crawler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility",
          "sqs:SetQueueAttributes",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:purgequeue"
        ]
        Resource = [aws_sqs_queue.s3_sqs_events.arn]
      }
    ]
  })
}
