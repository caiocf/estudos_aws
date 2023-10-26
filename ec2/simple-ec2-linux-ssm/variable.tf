variable "name_vpc" {
  description = "Nome da VPC da Conta, caso vazio ou não encontrar pelo nome ira usar a vpc padrão"
  default = null
}

variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"

  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}
