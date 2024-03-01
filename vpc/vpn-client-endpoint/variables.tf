variable "region" {
  description = "A região da AWS para deploy dos recursos."
  type        = string
  // "eu-central-1"   "us-east-1"
  default     = "eu-west-2" # Coloque o valor padrão ou deixe sem default para ser obrigatório
}


variable "config_dir" {
  type        = string
  description = "Local storage location for downloaded VPN config. Relative to module root."
  default     = "config"
}