
###########Não alterar###########
variable "control_account" {
  type        = string
  description = "Number of the Control Account"
  default = null
}
#################################
# Exemplos de variáveis que podem ser utilizadas no pipeline

variable "sor_db_name_source" {
  type        = string
  description = "Name of database SOR (db_source)"
  default = "db_source_clientes_dispositivo_sor_01"
}


variable "sor_s3bucket" {
  type        = string
  description = "Name of bucket sor s3://corp-sor-sa-east-1-<accountid producer>"
  default     = null
}

variable "spec_s3bucket" {
  type        = string
  description = "Name of bucket spec s3://corp-sor-sa-east-1-<accountid producer>"
  default = "s3://corp-sor-sa-east-1-"
}

variable "sor_table_name" {
  type        = string
  description = "Name of sor table"
  default = "dispositivo_autorizado"
}

variable "sor_table_name_2" {
  type        = string
  description = "Name of sor table"
  default = "dispositivo_autorizado_2"
}