# Outputs para referência
output "redshift_cluster_endpoint" {
  value = aws_redshift_cluster.redshift-cluster.endpoint
}

output "redshift_cluster_username" {
  value = aws_redshift_cluster.redshift-cluster.master_username
}

output "secrets_manager_arn" {
  value = aws_redshift_cluster.redshift-cluster.master_password_secret_arn
}

