resource "aws_security_group" "regra_http_ssh" {
  depends_on = [ module.criar_vpcA_regiao1]

  provider = aws.primary

  vpc_id = module.criar_vpcA_regiao1.vpc_id
  description = "Regra para SSH e ICMP e HTTP"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 8 # Código ICMP para Echo Request (ping)
    to_port     = 0 # ICMP não usa portas de destino, então configuramos como 0
    protocol    = "icmp"
    cidr_blocks = [module.criar_vpcA_regiao1.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # "-1" representa todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "keyPairSSH_1" {
  key_name   = "minhaChaveSSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAdimo5Jq8ZpxBX3AZKNYkkNwwoSxF1Acj+ZTYyyU5E9akCrXaEFZUq3+7xcW1ewrqvsvKw3aRQ+X/+ove2wl84nivF+6zsb7K0qjA5lmEIRGYCkls5f0wy4eFoBNM5mdAVrQYnE9F8HlPyLkLY3IlDEoisDGsInb5jW9Ebivdip1aD/Olwys3cxTIAdpUyE07kj9N+fQB8y8VtuRKF8Yc+qi/8dPK44G6ETjLHAj5kGoO84IRGMIONq5Grl2AeCPWCrgnn49yd7XC9Arl9pVYZnE3JRSwwQrMQ2byWWKrb1610plMG4XjzGWsN9TyLUry/aMjneprkYo4pEuIwMgt minhaChave" # Chave pública

  provider = aws.primary
}
