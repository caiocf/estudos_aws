variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "stream_name" {
  description = "Nome do Kinesis Data Stream"
  type        = string
  default     = "stream-output"
}

variable "shard_count" {
  description = "Quantidade de shards (modo provisionado)"
  type        = number
  default     = 2
}

variable "retention_hours" {
  description = "Retenção dos dados no stream (em horas). Padrão: 24h"
  type        = number
  default     = 24
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para armazenar os registros consumidos pela Lambda (precisa ser globalmente único)"
  type        = string
  default     = "meu-bucket-kinesis-data-stream-storage"
}

variable "lambda_name" {
  description = "Nome da função Lambda consumer (Kinesis -> S3)"
  type        = string
  default     = "kinesis-to-s3-consumer"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {
    Project = "kinesis-kds-lambda-s3"
    Owner   = "you"
  }
}
