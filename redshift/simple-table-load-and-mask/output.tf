output "user_redshift" {
  value = aws_redshift_cluster.default.master_username
}

output "pass_redshift" {
  value     = local.passwordMaster8Character
  #sensitive = true
}

output "endpoint_redshift" {
  value = aws_redshift_cluster.default.endpoint
}

output "role_redshift_spectrum" {
  value = aws_iam_role.redshift_s3_role.arn
}

output "nome_bucket" {
  value = aws_s3_bucket.sor_bucket.bucket
}

output "database_redshift" {
  value = aws_redshift_cluster.default.database_name
}