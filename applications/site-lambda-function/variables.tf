variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "ambiente_stage" {
  description = "Nome do ambiente"
  default = "dev"
}


variable "access_log_format" {
  description = "The format of the access log file."
  type        = string
  default     = <<EOF
  {
	"requestTime": "$context.requestTime",
	"requestId": "$context.requestId",
	"httpMethod": "$context.httpMethod",
	"path": "$context.path",
	"resourcePath": "$context.resourcePath",
	"status": $context.status,
	"responseLatency": $context.responseLatency,
  "xrayTraceId": "$context.xrayTraceId",
  "integrationRequestId": "$context.integration.requestId",
	"functionResponseStatus": "$context.integration.status",
  "integrationLatency": "$context.integration.latency",
	"integrationServiceStatus": "$context.integration.integrationStatus",
  "authorizeResultStatus": "$context.authorize.status",
	"authorizerServiceStatus": "$context.authorizer.status",
	"authorizerLatency": "$context.authorizer.latency",
	"authorizerRequestId": "$context.authorizer.requestId",
  "ip": "$context.identity.sourceIp",
	"userAgent": "$context.identity.userAgent",
	"principalId": "$context.authorizer.principalId",
	"cognitoUser": "$context.identity.cognitoIdentityId",
  "user": "$context.identity.user"
  }
  EOF
}

variable "http_methods" {
  description = "List of HTTP methods"
  type        = list(string)
  default     = ["GET", "POST", "DELETE"]
}

variable "bucket_versioning" {
  description = "(Optional) Variavel para habilitar ou desabilitar versionamento"
  type = string
  default = "Disabled"
  validation {
    condition = var.bucket_versioning == null || can(contains(["Enabled","Suspended","Disabled"],var.bucket_versioning))
    error_message = "Error ao configurar 'bucket_versioning'. Os valores aceitos são somente Enabled ou Disabled ou Suspended"
  }
}

variable "bucket_name" {
  description = "(Required) Nome do Bucket"
  type        = string
  default = "meu-site"
  nullable = false
  validation {
    condition = can(regex("^[a-z0-9.-]{3,63}$", var.bucket_name))
    error_message = "O nome do 'bucket_name' não é válido. Deve conter apenas letras minúsculas, números, traços e pontos, e ter entre 3 e 63 caracteres."
  }
}
