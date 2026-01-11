variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "source_bucket_name" {
  description = "Nome do bucket de origem"
  type        = string
  default     = "meu-bucket-origem-csv"
}

variable "destination_bucket_name" {
  description = "Nome do bucket de destino"
  type        = string
  default     = "meu-bucket-destino-csv"
}

variable "lambda_name" {
  description = "Nome da função Lambda"
  type        = string
  default     = "move-csv-between-buckets"
}
