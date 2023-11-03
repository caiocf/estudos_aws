resource "null_resource" "checkEc2InstanceProfile" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/check_instance_profile.sh ${local.ec2InstanceProfile} ${var.region} > ${path.module}/${local.pathEc2InstanceProfileFile}" # Substitua com o nome da sua keyPair e região desejada
    interpreter = ["bash", "-c"]
  }


}
