resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/api_gateway/${aws_api_gateway_rest_api.petstore_api.name}-${var.ambiente_stage}"
  retention_in_days = 7
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "api_gateway_cloudwatch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "apigateway.amazonaws.com",
      },
      Effect = "Allow",
      Sid = "",
    }],
  })
}

resource "aws_iam_policy" "api_gateway_cloudwatch_policy" {
  name   = "api_gateway_cloudwatch_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*",
      Effect   = "Allow",
    }],
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs_policy_attachment" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = aws_iam_policy.api_gateway_cloudwatch_policy.arn
}

resource "aws_api_gateway_account" "gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn

}
