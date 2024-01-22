
variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "name_redis_serverless" {
  description = "The name of the ElastiCache replication group."
  default     = "app-redis-serverless"
  type        = string
}

variable "namespace" {
  description = "Default namespace"
  default = ""
}