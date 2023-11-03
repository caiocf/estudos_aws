# Defina a versão do provider AWS
provider "aws" {
  region = var.region
}


resource "aws_security_group" "allow_ssh" {
  description = "Regra para SSH e ICMP"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # Código ICMP para Echo Request (ping)
    to_port     = 0 # ICMP não usa portas de destino, então configuramos como 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" representa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {

  depends_on = [
    null_resource.checkEc2InstanceProfile]
  ami = data.aws_ami.amazonLinux.id

  instance_type = var.instance_type
  iam_instance_profile = local.ec2InstanceProfileExist == false ? "" : local.ec2InstanceProfile

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/*.txt"
  }
}



