# Variável local para o ID da VPC
locals {
  keyNameSSH = "minhaChaveSSH-${timestamp()}${random_id.unique_suffix.hex}"
  //vpc_id = var.custom_vpc_id != try(data.aws_vpcs.vpcs.ids[0], data.aws_vpc.default)
  vpc_id = var.custom_vpc_id != "" ? var.custom_vpc_id : data.aws_vpc.default.id

  subnet_id = var.custom_subnet_id != "" ? var.custom_subnet_id : try( values(data.aws_subnet.subnets_list)[0].id, values(data.aws_subnet.subnets_list_public)[0].id)

  //keyNameSSHExist = try (data.aws_key_pair.keyNameSSH.key_name, "")

  valid_instance_types = data.aws_ec2_instance_types.available.instance_types
  //cidr_block = try( values(data.aws_subnet.subnets_list)[0].cidr_block, values(data.aws_subnet.subnets_list_public)[0].cidr_block)
}