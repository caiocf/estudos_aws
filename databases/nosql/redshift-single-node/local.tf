data "aws_caller_identity" "current" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  principal_root_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  principal_logs_arn = "logs.${var.region}.amazonaws.com"
  slow_log_arn       = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/redshift/${var.cluster_identifier}/slow-log"
  engine_log_arn     = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/redshift/${var.cluster_identifier}/engine-log"

  tags = {
    Example    = local.name
  }
}

