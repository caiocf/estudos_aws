resource "aws_elasticache_subnet_group" "meu_subnet_group" {
  name       = "meu-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "Meu DB Subnet Group Elastic cache"
  }
}


resource "aws_secretsmanager_secret" "elasticache_auth" {
  name                    = "app-4-elasticache-auth"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.encryption_secret.id
  #checkov:skip=CKV2_AWS_57: Disabled Secrets Manager secrets automatic rotation
}
resource "aws_secretsmanager_secret_version" "auth" {
  secret_id     = aws_secretsmanager_secret.elasticache_auth.id
  secret_string = random_password.auth.result
}

resource "aws_elasticache_replication_group" "app4" {
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.meu_subnet_group.name
  replication_group_id       = var.replication_group_id
  description                = "ElastiCache cluster for app4"
  node_type                  = "cache.t2.small"
  parameter_group_name       = "default.redis7.cluster.on"
  port                       = 6379
  multi_az_enabled           = true
  num_node_groups            = 2
  replicas_per_node_group    = 1
  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.encryption_rest.id
  transit_encryption_enabled = true
  auth_token                 = aws_secretsmanager_secret_version.auth.secret_string
  security_group_ids         = [aws_security_group.elastic_cache.id]
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
  lifecycle {
    ignore_changes = [kms_key_id]
  }
  apply_immediately = true
}

/*
resource "aws_elasticache_cluster" "app4" {
  cluster_id        = var.cluster_id
  engine            = "redis"
  node_type         = "cache.t3.micro"
  port              = 6379
  #auth_token =        aws_secretsmanager_secret_version.auth.secret_string # Substitua com seu token seguro

  parameter_group_name = "default.redis7.cluster.on" # Ajuste conforme a versão desejada
  engine_version       = "7.2"              # Especifique a versão do Redis

  provider = aws.primary
  subnet_group_name = aws_elasticache_subnet_group.meu_subnet_group.name

  snapshot_retention_limit = 5
  snapshot_window          = "00:00-05:00"


*/
/*  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.example.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_kinesis_firehose_delivery_stream.example.name
    destination_type = "kinesis-firehose"
    log_format       = "json"
    log_type         = "engine-log"
  }*//*


  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
  lifecycle {
    ignore_changes = [aws_kms_alias]
  }
  apply_immediately = true
}*/
