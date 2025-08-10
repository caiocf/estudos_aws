variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "outbox-cdc-msk"
}

variable "broker_instance_type" {
  type        = string
  default     = "kafka.m5.large"
}

variable "kafka_version" {
  type        = string
  default     = "3.6.0"
}

variable "msk_scram_username" {
  type        = string
  default     = "appclient"
  description = "Usuário SASL/SCRAM do MSK (prefixo AmazonMSK_ será aplicado automaticamente)"
}

variable "public_access_type" {
  type        = string
  default     = "DISABLED" # acesso público desativado (só clientes na VPC podem acessar).
  #default     = "SERVICE_PROVIDED_EIPS" # a AWS gerencia a configuração de acesso público para você:
}