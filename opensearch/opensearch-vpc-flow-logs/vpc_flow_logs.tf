data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_to_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = local.flow_logs_log_group_name
  retention_in_days = var.flow_logs_retention_in_days
  log_group_class   = "STANDARD"

  tags = {
    Name        = local.flow_logs_log_group_name
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = format("%s-vpc-flow-logs-role", var.domain_name)
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = {
    Name        = format("%s-vpc-flow-logs-role", var.domain_name)
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_to_cloudwatch" {
  name   = format("%s-vpc-flow-logs-to-cloudwatch", var.domain_name)
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_to_cloudwatch.json
}

resource "aws_flow_log" "default_vpc" {
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type     = "cloud-watch-logs"
  iam_role_arn             = aws_iam_role.vpc_flow_logs.arn
  traffic_type             = var.flow_logs_traffic_type
  max_aggregation_interval = var.flow_logs_max_aggregation_interval
  log_format               = local.flow_log_format
  vpc_id                   = data.aws_vpc.default.id

  tags = {
    Name        = format("%s-default-vpc-flow-log", var.domain_name)
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "vpc_flow_logs_to_opensearch" {
  name            = local.flow_logs_subscription_filter_name
  log_group_name  = aws_cloudwatch_log_group.vpc_flow_logs.name
  filter_pattern  = var.flow_logs_subscription_filter_pattern
  destination_arn = aws_lambda_function.flow_logs_to_opensearch.arn

  depends_on = [aws_lambda_permission.allow_cloudwatch_logs_invoke_flow_logs_lambda]
}
