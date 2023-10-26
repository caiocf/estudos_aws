module "criar_vpcA_regiao1" {
  source = "../"
  name_vpc = "VPC_A"

  cidr_vpc = "10.0.0.0/16"
  region = "us-east-1"
}

module "criar_vpcB_regiao2" {
  source = "../"
  name_vpc = "VPC_B"

  cidr_vpc = "192.168.0.0/16"
  region = "us-east-2"
}