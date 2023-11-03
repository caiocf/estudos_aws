# Output para mostrar o nome da função IAM
output "roleExist" {
  value = module.ec2_A.roleExist
}

output "keyPairExist" {
  value = module.ec2_A.keyPairExist
}

/*
output "roleExistB" {
  value = module.ec2_B.roleExist
}

output "keyPairExistB" {
  value = module.ec2_B.keyPairExist
}

*/




