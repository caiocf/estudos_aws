data "aws_iam_policy_document" "flow_logs_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "flow_logs_lambda_read_opensearch_credentials" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.opensearch_admin_credentials.arn]
  }
}

resource "aws_cloudwatch_log_group" "flow_logs_lambda" {
  name              = local.flow_logs_lambda_log_group_name
  retention_in_days = var.flow_logs_retention_in_days

  tags = {
    Name        = local.flow_logs_lambda_log_group_name
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_secretsmanager_secret" "opensearch_admin_credentials" {
  name                    = local.flow_logs_opensearch_secret_name
  recovery_window_in_days = 0

  tags = {
    Name        = local.flow_logs_opensearch_secret_name
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_secretsmanager_secret_version" "opensearch_admin_credentials" {
  secret_id = aws_secretsmanager_secret.opensearch_admin_credentials.id
  secret_string = jsonencode({
    password = random_password.admin_password.result
    username = var.master_user_name
  })
}

resource "aws_iam_role" "flow_logs_lambda" {
  name               = format("%s-flow-logs-lambda-role", var.domain_name)
  assume_role_policy = data.aws_iam_policy_document.flow_logs_lambda_assume_role.json

  tags = {
    Name        = format("%s-flow-logs-lambda-role", var.domain_name)
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }
}

resource "aws_iam_role_policy_attachment" "flow_logs_lambda_basic_execution" {
  role       = aws_iam_role.flow_logs_lambda.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "flow_logs_lambda_read_opensearch_credentials" {
  name   = format("%s-flow-logs-read-opensearch-credentials", var.domain_name)
  role   = aws_iam_role.flow_logs_lambda.id
  policy = data.aws_iam_policy_document.flow_logs_lambda_read_opensearch_credentials.json
}

resource "aws_lambda_function" "flow_logs_to_opensearch" {
  filename         = local.flow_logs_lambda_zip_path
  source_code_hash = local.flow_logs_lambda_source_code_hash
  function_name    = local.flow_logs_lambda_function_name
  role             = aws_iam_role.flow_logs_lambda.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.12"
  architectures    = ["x86_64"]
  timeout          = 60
  memory_size      = 256
  layers           = local.parameters_secrets_extension_layer_arn == null ? [] : [local.parameters_secrets_extension_layer_arn]

  environment {
    variables = {
      FLOW_LOG_FIELDS                        = jsonencode(local.flow_log_fields)
      INDEX_PREFIX                           = var.flow_logs_index_prefix
      OPENSEARCH_CREDENTIALS_SECRET_ARN      = aws_secretsmanager_secret.opensearch_admin_credentials.arn
      OPENSEARCH_ENDPOINT                    = local.opensearch_https_endpoint
      # Default local HTTP port used by the AWS Parameters and Secrets Lambda Extension.
      PARAMETERS_SECRETS_EXTENSION_HTTP_PORT = "2773"
      SECRETS_MANAGER_TTL                    = tostring(var.secrets_manager_ttl_seconds)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.flow_logs_lambda,
    aws_secretsmanager_secret_version.opensearch_admin_credentials,
  ]

  tags = {
    Name        = local.flow_logs_lambda_function_name
    Environment = "academic-flow-logs"
    ManagedBy   = "terraform"
    Study       = "opensearch"
  }

  lifecycle {
    precondition {
      condition     = local.parameters_secrets_extension_layer_arn != null
      error_message = "Não foi possível determinar o ARN da AWS Parameters and Secrets Lambda Extension para esta região. Defina parameters_secrets_extension_layer_arn explicitamente."
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_logs_invoke_flow_logs_lambda" {
  statement_id   = "AllowExecutionFromVpcFlowLogsGroup"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.flow_logs_to_opensearch.function_name
  principal      = "logs.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = local.vpc_flow_logs_source_log_group_arn
}
