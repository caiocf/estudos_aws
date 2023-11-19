terraform {
  required_version = ">= v1.6.1" # Substitua com a versão mínima desejada

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}