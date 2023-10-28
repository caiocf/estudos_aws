module "criar_vpcA_regiao1" {
  source = "../"

  cidr_vpc = "10.0.0.0/16"
  region = "us-east-1"
}
