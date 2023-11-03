resource "null_resource" "checkKeyPair" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/verificar_key_pair.sh ${local.keyNameSSH} ${var.region} > ${path.module}/${local.pathKeyPairFile}" # Substitua com o nome da sua keyPair e região desejada
    interpreter = ["bash", "-c"]
  }


}
