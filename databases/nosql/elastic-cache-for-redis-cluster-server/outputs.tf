output "endpoint_redis" {
  value = aws_ssm_parameter.elasticache_ep.name
}

output "port_redis" {
  value = aws_ssm_parameter.elasticache_port.name
}

output "token_redis" {
  value = aws_secretsmanager_secret.elasticache_auth.name
}