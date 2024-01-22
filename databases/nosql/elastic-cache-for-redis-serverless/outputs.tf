/*
output "endpoint_redis" {
  value = aws_elasticache_serverless_cache.app4.endpoint[0]["address"]
}

output "port_redis" {
   value = aws_elasticache_serverless_cache.app4.endpoint[0]["port"]
}

*/

output "endpoint_redis" {
  value = aws_ssm_parameter.elasticache_ep.name
}

output "port_redis" {
  value = aws_ssm_parameter.elasticache_port.name
}

output "token_secret_manager_redis" {
  value = aws_secretsmanager_secret.elasticache_auth.name
}

output "username_redis" {
  value = aws_elasticache_user.user_test.user_name
}