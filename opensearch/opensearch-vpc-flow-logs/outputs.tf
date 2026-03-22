output "domain_name" {
  description = "Nome do domínio OpenSearch criado."
  value       = aws_opensearch_domain.this.domain_name
}

output "domain_arn" {
  description = "ARN do domínio OpenSearch."
  value       = aws_opensearch_domain.this.arn
}

output "domain_endpoint" {
  description = "Endpoint principal do domínio OpenSearch."
  value       = aws_opensearch_domain.this.endpoint
}

output "domain_endpoint_dualstack" {
  description = "Endpoint DualStack, quando disponível."
  value       = try(aws_opensearch_domain.this.endpoint_v2, null)
}

output "dashboards_url" {
  description = "URL do OpenSearch Dashboards."
  value       = format("https://%s/_dashboards/", try(aws_opensearch_domain.this.endpoint_v2, aws_opensearch_domain.this.endpoint))
}

output "opensearch_admin_secret_arn" {
  description = "ARN do segredo no Secrets Manager usado pela Lambda para obter as credenciais do OpenSearch."
  value       = aws_secretsmanager_secret.opensearch_admin_credentials.arn
}

output "default_vpc_id" {
  description = "ID da VPC default usada para capturar os Flow Logs."
  value       = data.aws_vpc.default.id
}

output "vpc_flow_logs_log_group_name" {
  description = "Nome do CloudWatch Log Group que recebe os VPC Flow Logs."
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "vpc_flow_logs_index_pattern" {
  description = "Padrão de índice sugerido no OpenSearch Dashboards para consultar os Flow Logs."
  value       = local.flow_logs_index_pattern
}
