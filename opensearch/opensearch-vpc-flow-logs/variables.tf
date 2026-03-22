variable "aws_region" {
  description = "Região AWS onde o domínio OpenSearch será criado."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Nome do domínio OpenSearch."
  type        = string
  default     = "meucluser-opensearce"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,27}$", var.domain_name))
    error_message = "domain_name deve começar com letra minúscula e conter apenas letras minúsculas, números e hífen, com 3 a 28 caracteres."
  }
}

variable "availability_zone_count" {
  description = "Quantidade de zonas de disponibilidade (1, 2 ou 3)."
  type        = number
  default     = 3

  validation {
    condition     = contains([1, 2, 3], var.availability_zone_count)
    error_message = "availability_zone_count deve ser 1, 2 ou 3."
  }
}

variable "master_user_name" {
  description = "Nome do usuário administrador do OpenSearch Dashboards e API (FGAC)."
  type        = string
  default     = "admin"

  validation {
    condition     = length(var.master_user_name) >= 1 && length(var.master_user_name) <= 64
    error_message = "master_user_name deve ter entre 1 e 64 caracteres."
  }
}

variable "engine_version" {
  description = "Versão do motor OpenSearch. Ex.: OpenSearch_3.5"
  type        = string
  default     = "OpenSearch_3.5"

  validation {
    condition     = can(regex("^(OpenSearch|Elasticsearch)_[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "engine_version deve seguir o padrão OpenSearch_X.Y ou Elasticsearch_X.Y."
  }
}

variable "instance_type" {
  description = "Tipo da instância dos nós de dados."
  type        = string
  default     = "m5.large.search"
}

variable "data_node_count" {
  description = "Número de nós de dados do cluster."
  type        = number
  default     = 3

  validation {
    condition     = var.data_node_count >= 1
    error_message = "data_node_count deve ser maior ou igual a 1."
  }
}

variable "flow_logs_retention_in_days" {
  description = "Quantidade de dias para retenção dos logs do Flow Log e da Lambda."
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_logs_retention_in_days)
    error_message = "flow_logs_retention_in_days deve usar um valor suportado pelo CloudWatch Logs."
  }
}

variable "flow_logs_traffic_type" {
  description = "Tipo de tráfego capturado pelo VPC Flow Log."
  type        = string
  # Valores possíveis:
  # ALL    = registra tráfego aceito e rejeitado
  # ACCEPT = registra apenas tráfego aceito
  # REJECT = registra apenas tráfego rejeitado
  default = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "flow_logs_traffic_type deve ser ACCEPT, REJECT ou ALL."
  }
}

variable "flow_logs_max_aggregation_interval" {
  description = "Janela de agregação em segundos para os registros do VPC Flow Log."
  type        = number
  # Valores possíveis:
  # 60  = agrega os registros em janelas de 1 minuto
  # 600 = agrega os registros em janelas de 10 minutos
  default = 60

  validation {
    condition     = contains([60, 600], var.flow_logs_max_aggregation_interval)
    error_message = "flow_logs_max_aggregation_interval deve ser 60 ou 600."
  }
}

variable "flow_logs_index_prefix" {
  description = "Prefixo do índice usado no OpenSearch para os VPC Flow Logs."
  type        = string
  default     = "vpc-flow-logs"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.flow_logs_index_prefix))
    error_message = "flow_logs_index_prefix deve conter apenas letras minúsculas, números e hífen."
  }
}

variable "flow_logs_subscription_filter_pattern" {
  description = "Filtro opcional do CloudWatch Logs para limitar o que é enviado ao OpenSearch."
  type        = string
  default     = ""
}

variable "parameters_secrets_extension_layer_arn" {
  description = "ARN opcional da AWS Parameters and Secrets Lambda Extension. Se null, o projeto usa um valor conhecido para us-east-1 e sa-east-1."
  type        = string
  default     = null
}

variable "secrets_manager_ttl_seconds" {
  description = "TTL em segundos do cache da AWS Parameters and Secrets Lambda Extension para segredos do Secrets Manager."
  type        = number
  default     = 300

  validation {
    condition     = var.secrets_manager_ttl_seconds >= 0 && var.secrets_manager_ttl_seconds <= 300
    error_message = "secrets_manager_ttl_seconds deve estar entre 0 e 300 segundos."
  }
}
