data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allow_s3_sendmessage" {
  # (A) mantém o que você já tinha: S3 -> SQS (SendMessage)
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.s3_sqs_events.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.sor_bucket.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  # (B) NOVO: Glue crawler role -> SQS (consumir mensagens)
  statement {
    sid    = "AllowGlueCrawlerConsumeQueue"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.glue_crawler_role.arn]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [aws_sqs_queue.s3_sqs_events.arn]
  }
}

resource "aws_sqs_queue_policy" "s3_events_queue_policy" {
  queue_url = aws_sqs_queue.s3_sqs_events.id
  policy    = data.aws_iam_policy_document.allow_s3_sendmessage.json
}