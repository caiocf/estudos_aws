provider "aws" {
  alias  = "primary"
  region = "us-west-1"
}


module "criar_vpcA_regiao1" {
  source = "../"

  cidr_vpc = "10.0.0.0/16"

  providers = {
    aws = aws.primary
  }
}
