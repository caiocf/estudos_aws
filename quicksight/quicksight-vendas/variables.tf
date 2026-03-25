variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket_name" {
  type        = string
  description = "Nome do bucket S3 onde os dados de vendas serão armazenados"
  default     = null
}

variable "glue_db_name" {
  type        = string
  description = "Nome do database no Glue Catalog"
  default     = "db_vendas"
}

variable "glue_table_name" {
  type        = string
  description = "Nome da tabela externa no Glue Catalog"
  default     = "orders"
}

variable "athena_results_retention_days" {
  type        = number
  description = "Dias para expirar os resultados de queries do Athena no S3"
  default     = 30
}

variable "athena_workgroup_name" {
  type        = string
  description = "Nome do workgroup dedicado do Athena para este projeto"
  default     = "quicksight-vendas"
}

variable "athena_results_bucket_name" {
  type        = string
  description = "Nome do bucket S3 dedicado aos resultados das consultas do Athena deste projeto"
  default     = null
}

variable "force_destroy_buckets" {
  type        = bool
  description = "Quando true, permite que o Terraform remova buckets S3 mesmo que contenham objetos"
  default     = true
}

variable "quicksight_username" {
  type        = string
  description = "Username do QuickSight que terá acesso ao datasource (ex: admin)"
  default     = "admin"
}
