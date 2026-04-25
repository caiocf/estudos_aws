# -------------------------
# IAM role for Lambda
# -------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Permissão básica de logs
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política mínima para "mover" (ler do source, escrever no dest, deletar no source)
resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${var.lambda_name}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # List bucket (opcional, mas ajuda em alguns cenários)
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.source.arn,
          aws_s3_bucket.destination.arn
        ]
      },
      # Get/Delete no source (objetos)
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${aws_s3_bucket.source.arn}/*"
        ]
      },
      # Put no destination (objetos)
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ],
        Resource = [
          "${aws_s3_bucket.destination.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}