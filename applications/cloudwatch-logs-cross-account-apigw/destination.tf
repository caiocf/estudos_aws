locals {
  source_logs_arn_pattern      = "arn:aws:logs:${var.region}:${var.source_account_id}:*"
  destination_logs_arn_pattern = "arn:aws:logs:${var.region}:${var.destination_account_id}:*"
}

resource "aws_kinesis_stream" "apigw_logs" {
  provider         = aws.destination
  name             = var.stream_name
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = merge(var.tags, {
    Name    = var.stream_name
    Account = "destination"
  })
}

resource "aws_iam_role" "cwl_to_kinesis" {
  provider = aws.destination
  name     = "CWLtoKinesisRole-${replace(var.project_name, "_", "-")}"

  # CloudWatch Logs assumes this role in the destination account
  # so it can write incoming log events into Kinesis Data Streams.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringLike = {
            "aws:SourceArn" = [
              local.source_logs_arn_pattern,
              local.destination_logs_arn_pattern
            ]
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "CWLtoKinesisRole"
    Account = "destination"
  })
}

resource "aws_iam_role_policy" "cwl_to_kinesis" {
  provider = aws.destination
  name     = "PermissionsForCWLtoKinesis"
  role     = aws_iam_role.cwl_to_kinesis.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogsToWriteToKinesis"
        Effect = "Allow"
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Resource = aws_kinesis_stream.apigw_logs.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_destination" "cross_account" {
  provider   = aws.destination
  name       = var.destination_name
  role_arn   = aws_iam_role.cwl_to_kinesis.arn
  target_arn = aws_kinesis_stream.apigw_logs.arn
}

resource "aws_cloudwatch_log_destination_policy" "allow_source_account" {
  provider         = aws.destination
  destination_name = aws_cloudwatch_log_destination.cross_account.name

  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSourceAccountToCreateSubscriptionFilter"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.source_account_id}:root"
        }
        Action = "logs:PutSubscriptionFilter"
        Resource = aws_cloudwatch_log_destination.cross_account.arn
      }
    ]
  })
}
