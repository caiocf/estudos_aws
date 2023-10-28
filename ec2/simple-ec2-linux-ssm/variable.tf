variable "custom_vpc_id" {
  default = ""
  description = "Utilize o VPC id informado e não obter automaticamente"
}

variable "custom_subnet_id" {
  default = ""
  description = "Utilize o SUBNET id informado e não obter automaticamente"
}


variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "image_name_filter" {
  description = "O nome da AMI que sera filtrada: padrão amzn2-ami-hvm-*"
  default = "amzn2-ami-hvm-*"
}

variable "source_dest_check" {
  description = "Habilita na instancia atuar como NAT Instance na VPC. Por padrão é false"
  default = false
  type        = bool
  validation {
    condition     = can(tobool( var.source_dest_check))
    error_message = "A variável 'source_dest_check' deve ser um valor booleano.  Por padrão é false"
  }
}

variable "filter_type_subnet_public" {
  description = "Filtra pelo tipo da subnet publica(true) ou private(false). Por padrão é false"
  default = false
  type        = bool
  validation {
    condition     = can(tobool( var.filter_type_subnet_public))
    error_message = "A variável 'filter_type_subnet_public' deve ser um valor booleano.  Por padrão é false"
  }
}

variable "instance_type" {
  description = "Tipo da instancia. "
  default = "t2.micro"
}

variable "instance_name" {
  description = "Nome da Intancia"
  default = ""
}