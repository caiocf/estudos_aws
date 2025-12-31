data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "${var.glue_job_name}-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

data "aws_iam_policy_document" "glue_job_policy" {
  # S3 read bronzer + read script + write silver/tmp
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/${trim(var.bronze_prefix, "/")}/*",
      "${aws_s3_bucket.data.arn}/${trim(var.silver_prefix, "/")}/*",
      "${aws_s3_bucket.data.arn}/tmp/*",
      "${aws_s3_bucket.data.arn}/${trim(var.scripts_prefix, "/")}/*",
    ]
  }

  # CloudWatch Logs (logs do job)
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  # Glue Data Catalog enableUpdateCatalog=True
  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:CreateDatabase",
      "glue:GetTable",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetPartitions",
      "glue:BatchCreatePartition",
      "glue:BatchUpdatePartition"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "glue_job_policy" {
  name   = "${var.glue_job_name}-policy"
  policy = data.aws_iam_policy_document.glue_job_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_custom" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}
