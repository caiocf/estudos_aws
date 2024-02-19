module "criar_vpcA_regiao1" {
  source = "../../../../vpc/vpc-subnetpublic"
  name_vpc = "VPC_A"
  region =   "us-east-1"


  cidr_vpc = "172.31.0.0/16"
}
