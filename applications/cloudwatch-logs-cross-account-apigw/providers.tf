provider "aws" {
  alias   = "source"
  region  = var.region
  profile = var.source_profile
}

provider "aws" {
  alias   = "destination"
  region  = var.region
  profile = var.destination_profile
}
