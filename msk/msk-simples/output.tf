# Endpoints no cluster

output "bootstrap_brokers_sasl_iam" {
  description = "BootstrapBrokerStringSaslIam (porta 9098) — autenticação via IAM (SASL/IAM) privado"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_sasl_iam
}

output "bootstrap_brokers_tls" {
  description = "BootstrapBrokerStringTls (porta 9094) — TLS sem SASL privado"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_scram" {
  description = "BootstrapBrokerStringSaslScram (porta 9094) — autenticação via SASL/SCRAM"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_sasl_scram
}
output "bootstrap_brokers_public_sasl_iam" {
  description = "BootstrapBrokerStringSaslIamPubic (porta 9198) — autenticação via IAM (SASL/IAM) publico"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_public_sasl_iam
}

output "bootstrap_brokers_public_sasl_scram" {
  description = "BootstrapBrokerStringSaslScram (porta 9198) — autenticação via SASL/SCRAM"
  value       = aws_msk_cluster.cluster.bootstrap_brokers_public_sasl_scram
}


output "zookeeper_connect_string" {
  description = "String de conexão Zookeeper (modo ZK)"
  value       = aws_msk_cluster.cluster.zookeeper_connect_string
}

output "cluster_arn" {
  description = "ARN do cluster"
  value       = aws_msk_cluster.cluster.arn
}
