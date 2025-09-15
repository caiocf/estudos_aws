output "subnets_abc" {
  value = [
    data.aws_subnet.a.id,
    data.aws_subnet.b.id,
    data.aws_subnet.c.id
  ]
}


output "bootstrap_brokers_sasl_iam" {
  description = "BootstrapBrokerStringSaslIam (porta 9098) — autenticação via IAM (SASL/IAM) privado"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_sasl_iam
}
/*
output "rds_master_secret_arn" {
  value = aws_rds_cluster.this.master_user_secret[0].secret_arn
}
*/

output "cluster_arn"        {
  value = aws_rds_cluster.this.arn
}
output "writer_endpoint"    {
  value = aws_rds_cluster.this.endpoint
}

output "reader_endpoint"    {
  value = aws_rds_cluster.this.reader_endpoint
}

output "engine_version"     {
  value = aws_rds_cluster.this.engine_version
}

output "db_subnet_group"    {
  value = aws_db_subnet_group.this.name
}

