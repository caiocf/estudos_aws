variable "user_name" {
  description = "{Required} Nome do usuario que fara o assume role. Usuario deve ja esta criado!"
  default = "caiocf"
}

variable "arn_bucket" {
  description = "{Required} O nome do bucket"
  type        = string
  validation {
    condition     =   var.arn_bucket == null || can(regex("^[a-zA-Z0-9_.:/=+-@]{0,256}$", var.arn_bucket))
    error_message = "Erro ao configurar 'arn_bucket'. O valor deve ser um ARN válido"
  }
}


variable "role_name" {
  description = "{Required} Nome da Role"
  type = string

  validation {
    condition =   can(regex("^[a-zA-Z0-9_.:/=+-@]{1,128}$", var.role_name))
    error_message = "Erro ao configurar o 'role_name' do bucket. Conferir as regras definidas https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}

variable "policy_name" {
  description = "{Optional} Nome da Policy a ser criada"
  type = string
  default = "policy_storage_gateway_s3"

  validation {
    condition =  can(regex("^[a-zA-Z0-9_.:/=+-@]{1,128}$", var.policy_name))
    error_message = "Erro ao configurar o 'policy_name' do bucket. Conferir as regras definidas https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}

variable "policy_attachment_name" {
  description = "{Optional} Nome da Policy attachment"
  type = string
  default = "role_storage_gateway_s3_policy_attachment"
}