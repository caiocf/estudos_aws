variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  description = "(Required) Nome do Bucket"
  type        = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.bucket_name))
    error_message = "O nome do bucket não é válido. Deve conter apenas letras minúsculas, números, traços e pontos, e ter entre 3 e 63 caracteres."
  }
}

variable "bucket_versioning" {
  description = "(Optional) Variavel para habilitar ou desabilitar versionamento"
  type = string
  default = "Disabled"
  validation {
     condition = var.bucket_versioning == null || can(contains(["Enabled","Suspended","Disabled"],var.bucket_versioning))
     error_message = "Error ao configurar 'bucket_versioning'. Os valores aceitos são somente Enable ou Disabled"
  }
}
