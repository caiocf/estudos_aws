
# Output Oracle
output "oracle_endpoint" {
  value = split(":", aws_db_instance.default.endpoint)[0]
}
output "oracle_username" {
  value = aws_db_instance.default.username
}

output "oracle_db_name" {
  value = aws_db_instance.default.db_name
}

# Redshift
output "redshift_endpoint" {
  value = split(":", aws_redshift_cluster.default.endpoint)[0]
}
output "redshift_username" {
  value = aws_redshift_cluster.default.master_username
}

/*
# Output para referência
output "oracle_source_endpoint_arn" {
  value = aws_dms_endpoint.oracle_source.endpoint_arn
}

output "redshift_target_endpoint_arn" {
  value = aws_dms_endpoint.redshift_target.endpoint_arn
}
*/
