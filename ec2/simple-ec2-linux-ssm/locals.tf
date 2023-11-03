# Variável local para o ID da VPC
locals {
  resultado_null_resource = null_resource.check_role_exists.triggers
  resultado_null_resource_key_pair = null_resource.checkKeyPair.triggers
  resultado_null_resource_ec2_instance = null_resource.checkEc2InstanceProfile.triggers

  roleEc2Name = "ec2-role"
  pathRoleFile = "role_name.txt"
  roleExist = fileexists("${path.module}/${local.pathRoleFile}") == true ? trimspace(file("${path.module}/${local.pathRoleFile}")) != "": false
  //roleExist = fileexists("${path.module}/${local.pathRoleFile}") == true ? file("${path.module}/${local.pathRoleFile}") != "" : false


  //keyNameSSH = "minhaChaveSSH-${timestamp()}${random_id.unique_suffix.hex}"
  keyNameSSH = "minhaChaveSSH"
  pathKeyPairFile = "key_pair.txt"
  keyPairExist = fileexists("${path.root}/${local.pathKeyPairFile}") == true ? trimspace(file("${path.module}/${local.pathKeyPairFile}")) != "" : false
  //keyPairExist   = file("${path.module}/${local.pathKeyPairFile}") != "" ? true : false

  ec2InstanceProfile = "ec2-instance-profile"
  pathEc2InstanceProfileFile = "instance_profile.txt"
  ec2InstanceProfileExist = fileexists("${path.module}/${local.pathEc2InstanceProfileFile}") == true ? trimspace(file("${path.module}/${local.pathEc2InstanceProfileFile}")) != "" : false
  //ec2InstanceProfileExist = fileexists("${path.module}/${local.pathEc2InstanceProfileFile}") == true ? file("${path.module}/${local.pathEc2InstanceProfileFile}") != "" : false

  vpc_id = var.custom_vpc_id != "" ? var.custom_vpc_id : data.aws_vpc.default.id

  subnet_id = var.custom_subnet_id != "" ? var.custom_subnet_id : try( values(data.aws_subnet.subnets_list)[0].id, values(data.aws_subnet.subnets_list_public)[0].id)

  valid_instance_types = data.aws_ec2_instance_types.available.instance_types
  //cidr_block = try( values(data.aws_subnet.subnets_list)[0].cidr_block, values(data.aws_subnet.subnets_list_public)[0].cidr_block)
}