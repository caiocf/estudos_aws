provider "aws" {
  region = var.region
  alias  = "primary"
}

provider "random" {
  # Configuration options
}