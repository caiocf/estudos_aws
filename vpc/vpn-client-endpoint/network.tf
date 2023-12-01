module "criar_vpcA_regiao1" {
  source = "../vpc-subnetprivates-with-natinstance"
  name_vpc = "VPC_A"


  cidr_vpc = "172.31.0.0/16"
}
