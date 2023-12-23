variable "billing_mode_tf-table-users" {
  description = "PROVISIONED ou PAY_PER_REQUEST"
  type = string
  default = "PROVISIONED"
}

variable "write_capacity_tf-table-user" {
  description = "Numero de unidade de escrita (tabela)"
  type = number
  default = 5
}

variable "read_capacity_tf-table-user" {
  description = "Numero de unidade de leitura (tabela)"
  type = number
  default = 5
}

variable "write_capacity_gsi1-user" {
  description = "Numero de unidade de escrita (tabela)"
  type = number
  default = 5
}

variable "read_capacity_gsi1-user" {
  description = "Numero de unidade de leitura (tabela)"
  type = number
  default = 5
}

variable "ttl_tf-table-user" {
  description = "Expiracao de registro da tabela"
  default = true
}

variable "stream_enabled-user" {
  description = "true ou false"
  default = false
}

variable "stream_view_type-user" {
  description = "Stream Type: NEW_IMAGE, NEW_AND_OLD_IMAGES, NEW_AND_OLD_IMAGES, KEYS_ONLY"
  default = "NEW_AND_OLD_IMAGES"
}