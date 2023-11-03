# Variável local para o ID da VPC
locals {
  resultado_null_resource_key_pair = null_resource.checkKeyPair.triggers


  keyNameSSH = "minhaChaveSSH"
  pathKeyPairFile = "key_pair.txt"
  keyPairExist = fileexists("${path.module}/${local.pathKeyPairFile}") == true ? file("${path.module}/${local.pathKeyPairFile}") != "" : false
}