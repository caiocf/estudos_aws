variable "name" {
  description = "(Required) Nome do bucket"
  type        = string
  nullable    = false

  validation {
    condition = can(regex("^[a-z0-9.-]{3,63}$", var.name))
    error_message = "Erro ao configurar o 'name' do bucket. Conferir as regras definidas https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}


variable "cross_account_policy" {
  description = "(Required) Variavel para configurar acesso Cross Account ao Bucket"
  type = list(object({
      access_mode = string
      access_roles = list(string)
      organization_paths = list(string)

  }))
 /* default = [
    {
    access_mode = "Full"
    access_roles = ["arn:aws:iam::account_id:role/RoleName1", "arn:aws:iam::account_id:role/RoleName2"]
    organization_paths = ["ou=Finance,ou=Departments,dc=example,dc=com", "ou=HR,ou=Departments,dc=example,dc=com"]
    }
  ]*/

  validation {
    condition = alltrue( [ for p in var.cross_account_policy : contains(["Full","Read", "Write"], p.access_mode)  ] )
    error_message = "Erro ao configurar 'access_mode'"
  }
}

variable "name_suffix" {
  description = "(Optional) Definição de criação para cada ambiente (dev/hom/prod)"
  type = string
  default = "dev"

  validation {
    condition = can(regex("^[a-z0-9.-]{3,63}$", var.name_suffix))
    error_message = "Erro ao configurar o 'name_suffix' do bucket. Conferir as regras definidas https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html"
  }
}

## Tagging block
variable "s3_data_classification" {
  description = "(Required) Classificação do dados"
  type = string
  validation {
    condition = contains(["Restrito","Confidencial","Interna"],var.s3_data_classification)
    error_message = "Erro ao configurar 's3_data_classification'. Valores validos são Restrito, Confidencial e Interna"
  }
}

variable "s3_data_retention" {
  description = "(Required) Politica de retenção de dias dos dados"
  type = number
  default = 0
  validation {
    condition =  can(signum(var.s3_data_retention) >= 0)
    error_message = "Erro ao configurar 's3_data_retention'. O valores deve ser um inteiro positivo"
  }
}

## Information Block
variable "tags" {
  description = "(Optional) Tags extras para adicionar no bucket"
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = (
    length(var.tags) <= 50 &&                                     # Regra 1
    alltrue([for key, _ in var.tags : !startswith(key, "aws:")]) &&  # Regra 2
    #length(set([for key in keys(var.tags) : lower(key)])) == length(keys(var.tags)) &&  # Regra 3 (ignorando o caso)
    alltrue([for key in keys(var.tags) : can(regex("^[a-zA-Z0-9_.:/=+-@]{1,128}$", key))]) &&  # Regra 4
    alltrue([for value in values(var.tags) : can(regex("^[a-zA-Z0-9_.:/=+-@]{0,256}$", value))])  # Regra 5
    )
    error_message = "Erro ao configurar as 'tags'. Deve seguir as regras definidas no https://docs.aws.amazon.com/pt_br/tag-editor/latest/userguide/tagging.html."
  }
}

## Security black
variable "kms_id" {
  description = "(Optional) O ARN da chave do CMK para criptografar do bucket"
  type        = string
  default     = null
  validation {
    condition = var.kms_id == null || can(regex("^arn:aws:kms:\\w+(?:-\\w+)+:\\d{12}:(?:key|alias)\\/.+$",var.kms_id))
    error_message = "Erro ao configurar 'kms_id'. O valor deve ser um ARN valido"
  }
}

variable "bucket_policy" {
  description = "(Optional) Variavel para vincular policies adcionais ao bucket "
  type        = string
  default     = null
}

## Resource block
variable "force_destroy" {
  description = "(Optional) Variavel que habilita/desabilitar deletar todo o conteudo do bucket com o comando destroy do mesmo"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "(Optional) Variavel para habilitar ou desabilitar versionamento"
  type = string
  default = "Disabled"
  validation {
    condition =  contains(["Enabled","Suspended","Disabled"],var.versioning)
    error_message = "Error ao configurar 'bucket_versioning'. Os valores aceitos são somente Enabled ou Disabled ou Suspended"
  }
}

variable "lifecycle_versioning" {
  description = "(Optional) Variavel que configura as regras de expiração dos objetos versionados"
  type = object({
    keep_last_versions = optional(number, null)
    keep_for_days = optional(number, null)
  })
  default = {
    keep_last_versions = 3
    keep_for_days = 7
  }

  validation {
    condition = try(var.lifecycle_versioning.keep_last_versions,null) == null ||   can(signum(var.lifecycle_versioning.keep_last_versions) >= 0)
    error_message = "Erro ao configurar 'keep_last_versions'. O valor deve ser um inteiro nao nulo"
  }
  validation {
    condition = try(var.lifecycle_versioning.keep_for_days,null) == null ||  can(signum(var.lifecycle_versioning.keep_for_days) >= 0)
    error_message = "Erro ao configurar 'keep_for_days'. O valor deve ser um inteiro nao nulo"
  }
}

variable "lifecycle_transition" {
  description = "(Optional) Variavel que configura as regras de lifecyle"
  type = object({
    id          = optional(string, "Lifecycle intelligent tiering")
    status      = string
    transitions = optional(list(object({
      days = number
      storage_class = string
    })),[ ])
    nonconcurrent_version_transitions = optional(list(object({
      days = number
      storage_class = string
    })),[ ])
  })
  default = {
    status = "Enabled"
    transitions = [
      {
        days = 0
        storage_class = "INTELLIGENT_TIERING"
      }
    ]
    nonconcurrent_version_transitions = [
      {
        days = 0
        storage_class = "INTELLIGENT_TIERING"
      }
    ]
  }

  validation {
    condition =   var.lifecycle_transition.status != null || can(contains(["Enabled", "Disabled"], var.lifecycle_transition.status))
    error_message = "Erro ao configurar 'status'. Deve ser 'Enabled' ou 'Disabled'."
  }

  validation {
    condition = alltrue([for t in var.lifecycle_transition.transitions : can(index(["STANDARD", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE"], t.storage_class))])
    error_message = "Erro ao configurar 'transitions'. O campo 'storage_class' deve conter valores válidos (STANDARD, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE)."
  }

  validation {
    condition = alltrue([for t in var.lifecycle_transition.nonconcurrent_version_transitions : can(index(["STANDARD", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE"], t.storage_class))])
    error_message = "Erro ao configurar 'concurrent_version_transitions'. O campo 'storage_class' deve conter valores válidos (STANDARD, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE)."
  }
  validation {
    condition = alltrue([for t in var.lifecycle_transition.transitions : can(signum(t.days) > 0) ])
    error_message = "Erro ao configurar 'transitions'. Os valores de 'days' em todas as transições devem ser números positivos."
  }

  validation {
    condition = alltrue([for t in var.lifecycle_transition.nonconcurrent_version_transitions : can(signum(t.days) > 0) ])
    error_message = "Erro ao configurar 'noconcurrent_version_transitions'. Os valores de 'days' em todas as transições devem ser números positivos."
  }
}

variable "lifecycle_multipart" {
  description = "(Optional) Variavel que habilita/desabilita a função aborta o upload multipart."
  type = object({
    id        = optional(string, "Incomplete multipart upload")
    status    = string
    days_after_initiation = optional(number,7)
  })
  default = {
    status = "Enabled"
  }

  validation {
    condition = var.lifecycle_multipart.status == null || can(contains(["Enabled","Disabled"],var.lifecycle_multipart.status))
    error_message = "Erro ao configurar 'status'. Deve ser 'Enabled' ou 'Disabled'."
  }

  validation {
    condition = can(signum(var.lifecycle_multipart.days_after_initiation) >= 0)
    error_message = "Erro ao configurar 'days_after_initiation'. Deve ser numero positivo"
  }
}

variable "intelligent_tiering" {
  description = "(Optional) Variavel que configura as regras de lifecyle"
  type = object({
    name = optional(string,"EntireBucket")
    status = string
    tierings = list(object({
      days   = number
      access_tier  = string
    }))
  })

  default = {
    status = null,
    tierings = []
  }

  validation {
    condition = var.intelligent_tiering.status == null || can(contains(["Enabled","Disabled"],var.intelligent_tiering.status))
    error_message = "Erro ao configurar 'status'. Deve ser 'Enabled' ou 'Disabled'."
  }

  validation {
    condition = alltrue([ for t in var.intelligent_tiering.tierings : can(signum(t.days) >= 0) ])
    error_message = "Erro ao configurar 'tierings_days'. Deve ser numero positivo"
  }

  validation {
    condition = alltrue([ for t in var.intelligent_tiering.tierings : contains(["ARCHIVE_ACCESS","DEEP_ARCHIVE_ACCESS"],t.access_tier) ])
    error_message = "Erro ao configurar 'tierings_access_tier'. Deve ser DEEP_ARCHIVE ou DEEP_ARCHIVE"
  }
}