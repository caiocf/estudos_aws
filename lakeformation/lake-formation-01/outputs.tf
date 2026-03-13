# Outputs para facilitar acesso às informações dos recursos criados

output "bucket_name" {
  description = "Nome do bucket S3 do Data Lake"
  value       = aws_s3_bucket.glue_lake.id
}

output "bucket_arn" {
  description = "ARN do bucket S3 do Data Lake"
  value       = aws_s3_bucket.glue_lake.arn
}

output "database_name" {
  description = "Nome do database no Glue Catalog"
  value       = aws_glue_catalog_database.main.name
}

output "customers_table_name" {
  description = "Nome da tabela customers"
  value       = aws_glue_catalog_table.customers.name
}

output "athena_workgroup_name" {
  description = "Nome do Athena workgroup"
  value       = aws_athena_workgroup.main.name
}

output "iam_user_name" {
  description = "Nome do usuário IAM criado"
  value       = aws_iam_user.aws_user.name
}

output "iam_user_arn" {
  description = "ARN do usuário IAM criado"
  value       = aws_iam_user.aws_user.arn
}

output "lakeformation_data_access_role_arn" {
  description = "ARN da role usada para registrar a data location no Lake Formation"
  value       = aws_iam_role.lakeformation_data_access.arn
}

output "vpc_endpoint_s3_id" {
  description = "ID do VPC Endpoint S3 Gateway"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_glue_id" {
  description = "ID do VPC Endpoint Glue Interface"
  value       = aws_vpc_endpoint.glue.id
}
