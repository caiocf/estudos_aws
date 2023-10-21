# Defina a versão do provider AWS
provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" representa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "minha_chave" {
  key_name   = "minhaChaveSSH" # Nome da chave
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAdimo5Jq8ZpxBX3AZKNYkkNwwoSxF1Acj+ZTYyyU5E9akCrXaEFZUq3+7xcW1ewrqvsvKw3aRQ+X/+ove2wl84nivF+6zsb7K0qjA5lmEIRGYCkls5f0wy4eFoBNM5mdAVrQYnE9F8HlPyLkLY3IlDEoisDGsInb5jW9Ebivdip1aD/Olwys3cxTIAdpUyE07kj9N+fQB8y8VtuRKF8Yc+qi/8dPK44G6ETjLHAj5kGoO84IRGMIONq5Grl2AeCPWCrgnn49yd7XC9Arl9pVYZnE3JRSwwQrMQ2byWWKrb1610plMG4XjzGWsN9TyLUry/aMjneprkYo4pEuIwMgt minhaChave" # Chave pública
}


resource "aws_instance" "this" {
  ami = data.aws_ami.amazonLinux.id

  instance_type = "t2.micro"

  key_name = aws_key_pair.minha_chave.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.allow_ssh.name]

  associate_public_ip_address = true
  user_data = <<EOF
              #!/bin/bash
              # Instalação do SSM Agent
              yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
              EOF
}