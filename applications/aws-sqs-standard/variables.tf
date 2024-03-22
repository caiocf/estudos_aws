
variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "nome_fila_padrao" {
  type = string
  default = "minha-fila-padrao"
}

variable "nome_fila_dlq" {
  type = string
  default = "minha-fila-dlq"
}