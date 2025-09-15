variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "outbox-cdc-msk"
}


variable "db_name_instance" {
  type        = string
  default     = "aurora-pg16-slsv2-demo"
}

variable "broker_instance_type" {
  description = "Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large. ([Pricing info](https://aws.amazon.com/msk/pricing/))"
  type        = string
  default     = "kafka.t3.small"
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

variable "db_app_user" {
  type        = string
  default     = "debezium"
  description = "Usuário de aplicação para CDC"
}
