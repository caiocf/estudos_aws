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

module "ec2_A" {
  source = "../../../ec2/simple-ec2-linux-ssm"
  region = "us-east-1"

  custom_vpc_id = module.criar_vpcA_regiao1.vpc_id
  custom_subnet_id = module.criar_vpcA_regiao1.subnet_a_id
  instance_name = "ec2_A"
}

module "ec2_B" {
  source = "../../../ec2/simple-ec2-linux-ssm"
  region = "us-east-2"

  custom_vpc_id = module.criar_vpcB_regiao2.vpc_id
  custom_subnet_id = module.criar_vpcB_regiao2.subnet_a_id
  instance_name = "ec2_B"
}