
variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"

  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "name_vpc" {
  default = "VPC-PRODUCT"
  validation {
    condition = (
    length(var.name_vpc) <= 50 &&                                     # Regra 1
    !startswith(var.name_vpc, "aws:") &&  # Regra 2
    can(regex("^[a-zA-Z0-9_.:/=+-@]{1,128}$", var.name_vpc)))
    error_message = "Erro ao configurar as 'tags'. Deve seguir as regras definidas no https://docs.aws.amazon.com/pt_br/tag-editor/latest/userguide/tagging.html."
  }
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"

  validation {
    condition = can(regex("^(10\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})|172\\.(1[6-9]|2[0-9]|3[0-1])\\.(\\d{1,3})\\.(\\d{1,3})|192\\.168\\.(\\d{1,3})\\.(\\d{1,3}))\\/(1[6-9]|2[0-8])$", var.cidr_vpc))

    error_message = "O bloco CIDR não está no formato correto ou não está dentro de um intervalo de IP privado"
  }
}
