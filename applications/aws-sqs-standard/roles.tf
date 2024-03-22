resource "aws_iam_role" "sqs_writer_role" {
  name = "sqs_writer_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

data "aws_iam_policy_document" "sqs_write_policy_doc" {
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]
    resources = [
      aws_sqs_queue.my_queue.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "sqs_write_policy" {
  name   = "sqs_write_policy"
  policy = data.aws_iam_policy_document.sqs_write_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_writer_policy_attachment" {
  role       = aws_iam_role.sqs_writer_role.name
  policy_arn = aws_iam_policy.sqs_write_policy.arn
}

resource "aws_iam_role" "sqs_reader_role" {
  name = "sqs_reader_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

data "aws_iam_policy_document" "sqs_read_policy_doc" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [
      aws_sqs_queue.my_queue.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "sqs_read_policy" {
  name   = "sqs_read_policy"
  policy = data.aws_iam_policy_document.sqs_read_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_reader_policy_attachment" {
  role       = aws_iam_role.sqs_reader_role.name
  policy_arn = aws_iam_policy.sqs_read_policy.arn
}
