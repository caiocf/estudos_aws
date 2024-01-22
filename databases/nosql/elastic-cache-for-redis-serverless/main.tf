resource "aws_elasticache_subnet_group" "meu_subnet_group" {
  name       = "meu-subnet-group"
  subnet_ids = [module.criar_vpcA_regiao1.subnet_a_id,module.criar_vpcA_regiao1.subnet_b_id,module.criar_vpcA_regiao1.subnet_c_id]

  tags = {
    Name = "Meu DB Subnet Group Elastic cache"
  }
}

resource "aws_secretsmanager_secret" "elasticache_auth" {
  name                    = "app-4-elasticache-auth-serverless"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.encryption_secret.id
  #checkov:skip=CKV2_AWS_57: Disabled Secrets Manager secrets automatic rotation
}
resource "aws_secretsmanager_secret_version" "auth" {
  secret_id     = aws_secretsmanager_secret.elasticache_auth.id
  secret_string = random_password.auth.result
}

resource "aws_elasticache_user" "user_test" {
  user_id       = "test-userid"
  user_name     = "redis-user"
  access_string = "on ~* +@all"
  #access_string = "on ~app::* -@all +@read +@hash +@bitmap +@geo -setbit -bitfield -hset -hsetnx -hmset -hincrby -hincrbyfloat -hdel -bitop -geoadd -georadius -georadiusbymember"
  #access_string = "access_string = "on ~app::* +@all -@dangerous"
  engine        = "REDIS"
  passwords     = [aws_secretsmanager_secret_version.auth.secret_string]
}

resource "aws_elasticache_user_group" "group_test" {
  depends_on = [aws_elasticache_user.user_test]
  engine        = "REDIS"
  user_group_id = "user-groupid"
  user_ids      = ["default",aws_elasticache_user.user_test.user_id]
}

resource "aws_elasticache_serverless_cache" "app4" {
  depends_on = [aws_elasticache_user_group.group_test]
  engine = "redis"
  name   = var.name_redis_serverless
  user_group_id           = aws_elasticache_user_group.group_test.user_group_id

/*  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5
    }
  }*/
  daily_snapshot_time      = "09:00"
  description              = "ElastiCache cluster for app4 serverless"
  kms_key_id               = aws_kms_key.encryption_rest.arn
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.elastic_cache.id]
  subnet_ids               = aws_elasticache_subnet_group.meu_subnet_group.subnet_ids

  provider = aws.primary
}

