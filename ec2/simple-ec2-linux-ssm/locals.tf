# Variável local para o ID da VPC
locals {
  vpc_id = try(data.aws_vpcs.vpcs.ids[0], data.aws_vpc.default)

  first_subnet_id = values(data.aws_subnet.subnets_list)[0].id
  cidr_block = values(data.aws_subnet.subnets_list)[0].cidr_block
}