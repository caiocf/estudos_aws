resource "null_resource" "check_role_exists" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/check_role_existence.sh ${local.roleEc2Name} > ${path.module}/${local.pathRoleFile}" # Substitua "ec2-role" pelo nome desejado da função IAM
    interpreter = ["bash", "-c"]
  }
}


