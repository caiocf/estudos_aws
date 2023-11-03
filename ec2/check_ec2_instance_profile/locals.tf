# Variável local para o ID da VPC
locals {
  resultado_null_resource_instance_profile = null_resource.checkEc2InstanceProfile.triggers


  ec2InstanceProfile = "ec2-instance-profile"
  pathEc2InstanceProfileFile = "instance_profile.txt"
  ec2InstanceProfileExist = fileexists("${path.module}/${local.pathEc2InstanceProfileFile}") == true ? trimspace(file("${path.module}/${local.pathEc2InstanceProfileFile}")) != "" : false
}