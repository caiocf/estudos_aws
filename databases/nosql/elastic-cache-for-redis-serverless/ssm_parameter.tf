#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "elasticache_ep" {
  name   = "/elasticache/app-4/${aws_elasticache_serverless_cache.app4.name}/endpoint"
  type   = "SecureString"
  key_id = aws_kms_key.encryption_rest.id
  value  = aws_elasticache_serverless_cache.app4.endpoint[0]["address"]
}



resource "aws_ssm_parameter" "elasticache_port" {
  name   = "/elasticache/app-4/${aws_elasticache_serverless_cache.app4.name}/port"
  type   = "SecureString"
  key_id = aws_kms_key.encryption_rest.id
  value  = aws_elasticache_serverless_cache.app4.endpoint[0]["port"]
}

