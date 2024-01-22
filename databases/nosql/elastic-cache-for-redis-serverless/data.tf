data "aws_caller_identity" "current" {}

locals {
  principal_root_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  principal_logs_arn = "logs.${var.region}.amazonaws.com"
  slow_log_arn       = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/elasticache/${var.name_redis_serverless}/slow-log"
  engine_log_arn     = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/elasticache/${var.name_redis_serverless}/engine-log"
}

data "aws_ami" "amazonLinux_regiao1"{
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]

  provider = aws.primary
}