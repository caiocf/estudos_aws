# Defina a versão do provider AWS
provider "aws" {
  region = var.region
}



resource "random_id" "unique_suffix" {
  byte_length = 4
}

resource "aws_security_group" "allow_ssh" {
  vpc_id = local.vpc_id
  #name = "allow-ssh-icmp"
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
 /* tags = {
    Name = "allow-ssh-icmp"
  }*/
}

resource "aws_key_pair" "keyPairSSH" {
  depends_on = [null_resource.checkKeyPair]

  count =  local.keyPairExist == false ? 1 : 0
  key_name   = local.keyNameSSH # Nome da chave
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAdimo5Jq8ZpxBX3AZKNYkkNwwoSxF1Acj+ZTYyyU5E9akCrXaEFZUq3+7xcW1ewrqvsvKw3aRQ+X/+ove2wl84nivF+6zsb7K0qjA5lmEIRGYCkls5f0wy4eFoBNM5mdAVrQYnE9F8HlPyLkLY3IlDEoisDGsInb5jW9Ebivdip1aD/Olwys3cxTIAdpUyE07kj9N+fQB8y8VtuRKF8Yc+qi/8dPK44G6ETjLHAj5kGoO84IRGMIONq5Grl2AeCPWCrgnn49yd7XC9Arl9pVYZnE3JRSwwQrMQ2byWWKrb1610plMG4XjzGWsN9TyLUry/aMjneprkYo4pEuIwMgt minhaChave" # Chave pública
}

resource "aws_instance" "this" {

  depends_on = [aws_security_group.allow_ssh,
    aws_iam_instance_profile.ec2_instance_profile,
    null_resource.checkKeyPair,
    null_resource.check_role_exists,
    aws_iam_instance_profile.ec2_instance_profile,
    null_resource.checkEc2InstanceProfile]
  ami = data.aws_ami.amazonLinux.id

  instance_type = var.instance_type

  key_name = local.keyPairExist == true ? local.keyNameSSH : aws_key_pair.keyPairSSH[0].key_name
  iam_instance_profile = local.ec2InstanceProfileExist == true ? local.ec2InstanceProfile : aws_iam_instance_profile.ec2_instance_profile[0].name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = local.subnet_id

  source_dest_check = var.source_dest_check

  tags = {
    Name = var.instance_name
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/*.txt"
  }

  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
              EOF
}


