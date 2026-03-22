terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}
