
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

variable "instance_type" {
  description = "Tipo da instancia. "
  default = "t2.micro"
}